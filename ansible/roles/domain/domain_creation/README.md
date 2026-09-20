# Active Directory Domain Creation and Replication

A **_domain infrastructure_** setup for the `khangvum.com` forest, which involves promoting `KVM-DC01` as the **_primary domain controller_** (**_PDC_**), joining `KVM-DC02` as a **_secondary domain controller_**, and ensuring **_multi-master replication_** across the environment.

## Domain Controller Roles

Domain Controller   |Role
:------------------:|----
`KVM-DC01`          |Hold all the **_Flexible Single Master Operations_** (**_FSMO_**) **_roles_** and act as the **_primary NTP time source_**
`KVM-DC02`          |Provide **_high availability_** (**_HA_**) and **_fault tolerance_** if the PDC is offline

## Time Synchronization

**_Replication integrity_** depends on **_Kerberos_** authentication protocol, which requires synchronized system clocks:

Domain Controller   |Sync Source
:------------------:|-----------
`KVM-DC01`          |External **_NTP source_** (_e.g.,_ `0.pool.ntp.org,0x1`, `1.pool.ntp.org,0x1`)
`KVM-DC02`          |Internal **_domain hierarchy_** (**_NT5DS_**)

This is configured in [`windows_ntp_configuration`](../../general/windows_ntp_configuration/tasks/main.yml) role.

## Replication Management

Active Directory uses **_multi-master replication_** to maintain **_identical copies_** of the **_NTDS database_** on both DCs, ensuring any changes made on any DC eventually converges across the entire forest.

### Force Synchronization

**_Force synchronization_** between all domain controllers:

```powershell
repadmin /syncall /AeP
```

-   `/A`: All partitions.
-   `/e`: Enterprise/Entire forest.
-   `/P`: Push changes out to all its partners.

### Health Monitoring

Verify **_replication health_** with **_no replication latencies_**:

```powershell
repadmin /replsummary
```