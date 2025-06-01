# Security Policy

## 1. Container Hardening
### Capability Restrictions
- Drop all capabilities by default
- Allow only: CHOWN, DAC_OVERRIDE, FOWNER, FSETID, KILL, SETGID, SETUID, SETPCAP, NET_BIND_SERVICE, SYS_CHROOT, SETFCAP

### User Namespaces
- Enable user namespace remapping
- Use non-root user in containers
- UID/GID range: 10000-65536

### Filesystem Restrictions
- Read-only root filesystem
- Tmpfs for /tmp (size=10M)
- Allow-listed volume mounts only

### Resource Limits
```yaml
deploy:
  resources:
    limits:
      cpus: '0.5'
      memory: 100M
      pids: 50
```

## 2. Network Security
- Default: `network_mode: none`
- Outbound allowlist only for required domains
- Connection rate limiting
- Port scanning detection

## 3. Runtime Protection
- Daily vulnerability scans (Trivy)
- Runtime behavior analysis (Falco)
- Seccomp profiles for syscall filtering
- AppArmor enforcement

## 4. Secrets Management
- HashiCorp Vault integration
- Short-lived credentials
- Automatic secret rotation
- Audit logging for secret access

## 5. Compliance
- CIS Docker Benchmark enforcement
- GDPR/CCPA data handling procedures
- Quarterly penetration testing
- Audit trail preservation (1 year)

## Security Testing (Deprecated)

The automated security test suite was removed on 2025-06-01. Security verification is now performed through:

1. Manual testing during releases
2. Code review of container configuration
3. Runtime monitoring with Falco
4. Periodic penetration testing

Key security controls remain:
- Read-only root filesystem
- Network isolation
- Resource limits
- Non-root execution