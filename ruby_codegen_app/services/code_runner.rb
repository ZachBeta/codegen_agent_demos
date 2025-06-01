require 'docker'
require 'timeout'

class CodeRunner
  DEFAULT_TIMEOUT = 5 # seconds
  DOCKER_IMAGE = 'ruby:3.3-slim'
  ALLOWED_CAPABILITIES = %w[CHOWN DAC_OVERRIDE FOWNER FSETID KILL SETGID SETUID SETPCAP NET_BIND_SERVICE SYS_CHROOT SETFCAP NET_ADMIN]

  def initialize
    # Set explicit Docker socket path matching CLI
    Docker.options = {
      read_timeout: 300,
      connect_timeout: 5,
      socket: '/var/run/docker.sock'  # Standard Docker socket path
    }
    @container = nil
    ensure_docker_image
  end

  def run(code, input, timeout: DEFAULT_TIMEOUT)
    create_container
    @container.start
    result = execute_code(code, input, timeout)
    cleanup_container
    result
  rescue Docker::Error::NotFoundError => e
    { error: "Docker image not found. Please run 'docker pull #{DOCKER_IMAGE}'", status: :failed }
  rescue => e
    cleanup_container
    { error: e.message, status: :failed }
  end

  private

  def ensure_docker_image
    # First try to get existing image
    Docker::Image.get(DOCKER_IMAGE)
  rescue Docker::Error::NotFoundError => e
    puts "Image not found locally, attempting to pull #{DOCKER_IMAGE}..."
    begin
      # Pull with progress reporting
      Docker::Image.create('fromImage' => DOCKER_IMAGE) do |chunk|
        puts "Pull progress: #{chunk}" if chunk.is_a?(Hash)
      end
      Docker::Image.get(DOCKER_IMAGE)
    rescue => e
      raise "Failed to pull Docker image: #{e.message}\nPlease ensure Docker is running and you have network access."
    end
  end

  def create_container
    @container = Docker::Container.create(
      'Image' => DOCKER_IMAGE,
      'Tty' => false,
      'ReadonlyRootfs' => true,
      'NetworkDisabled' => true,
      'HostConfig' => {
        'Memory' => 100 * 1024 * 1024, # 100MB
        'CpuShares' => 512,
        'PidsLimit' => 10, # Reduced from 50
        'AutoRemove' => true,
        'CapDrop' => ['ALL'],
        'CapAdd' => [], # Removed all capabilities
        'SecurityOpt' => [
          'no-new-privileges',
          'apparmor:docker-default',
          'seccomp=/etc/docker/seccomp/default.json'
        ],
        'Tmpfs' => {
          '/tmp' => 'rw,noexec,nosuid,size=1M' # Reduced size
        },
        'UsernsMode' => 'host',
        'ReadonlyPaths' => ['/'],
        'TmpfsOptions' => {
          'mode' => '1777',
          'uid' => '10000',
          'gid' => '10000'
        }
      },
      'User' => '10000:10000' # Hardcoded non-root user
    )
  end

  def execute_code(code, input, timeout)
    Timeout.timeout(timeout) do
      # Write code to container
      @container.store_file('/tmp/code.rb', code)
      
      # Execute with input and capture full output
      exec = @container.exec(
        ['sh', '-c', 'ruby /tmp/code.rb 2>&1'], # Redirect stderr to stdout
        stdin: StringIO.new(input.to_s)
      )
      
      # Parse combined output for errors
      full_output = exec[0].join
      status = exec[2] == 0 ? :success : :failed
      
      {
        output: full_output,
        errors: status == :failed ? full_output : '',
        status: status
      }
    end
  rescue Timeout::Error
    { error: 'Execution timed out', status: :timeout }
  rescue => e
    { error: "Container error: #{e.message}", status: :failed }
  end

  def cleanup_container
    @container&.delete(force: true) if @container
  rescue
    nil
  end
end