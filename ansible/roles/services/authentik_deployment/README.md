# Authentik Identity Provider Deployment

An **_Ansible role_** facilitates the **_identity provider deployment_** process for **_Authentik_** (_e.g.,_ KVM-IAM01), providing a centralized, secure authentication layer for the homelab.

## 1. Domain Controller LDAP Certificate Setup

1. Generate **_self-signed certificates_** on `KVM-DC01`:

- Open **_PowerShell as Administrator_** and execute:

  ```powershell
  New-SelfSignedCertificate -DnsName "kvm-dc01.khangvum.com", "kvm-dc02.khangvum.com" -CertStoreLocation "cert:\LocalMachine\My" -NotAfter (Get-Date).AddYears(5)
  ```

- Open **_Certificate Manager_** (`certlm.msc`):
  - Navigate to **Personal** > **Certificates**.
  - Right click the certificate > **All Tasks** > **Export...**
  - Select **Yes, export the private key** and choose **Personal Information Exchange (.PFX)**.
  - Set a password and save the file.

2. **_Deploy_** the certificate to `KVM-DC02`:

- **_Copy_** the `.pfx` file to `KVM-DC02`.
- Open `certlm.msc` on `KVM-DC02`, navigate to **Personal** > **Certificates**.
- Right-click > **All Tasks** > **Import...** and follow the wizard to install the `.pfx` file.

3. **_Trust_** the **_certificate_**:

- On **_both DCs_**, navigate to **Personal** > **Certificates** in `certlm.msc`.
- **_Copy_** the certificate and **_paste_** it into **Trusted Root Certification Authorities** > **Certificates**.

4. **_Export_** the **_root certificate_** for **_Authentik_**:

- In **_Certificate Manager_** (`certlm.msc`), under **_Trusted Root Certification Authorities_**, locate the certificate.
- Right click > **All Tasks** > **Export...**
- Select **No, do not export the private key**.
- Choose **_Base-64 encoded X.509 (.CER)_** and save it as `dc_root.cer`.
- Transfer `dc_root.cer` to the management machine.

## 2. Authentik Source Integration

- In the **_Authentik Admin Interface_**, navigate to **_System_** > **_Certificates_**.
- Click **_Import Existing Certificate-Key Pair_**.
- Fill out the details:

  |       Property       | Value                                                                   |
  | :------------------: | :---------------------------------------------------------------------- |
  | **Certificate Name** | `AD-SelfSigned-Root`                                                    |
  |   **Certificate**    | Paste the text content of `dc_root.cer` (including `BEGIN`/`END` lines) |
  |   **Private Key**    | Leave empty                                                             |

- Click **Import Certificate-Key Pair**.
- Navigate to **Directory** > **Federation and Social login** and click **New Source**.

  |             Property             | Value                                                                 |
  | :------------------------------: | --------------------------------------------------------------------- |
  |             **Name**             | `khangvum.com`                                                        |
  |          **Server URI**          | `ldaps://kvm-dc01.khangvum.com:636,ldaps://kvm-dc02.khangvum.com:636` |
  | **TLS Verification Certificate** | Select `AD-SelfSigned-Root`                                           |
  |           **Bind CN**            | `CN=Administrator,CN=Users,DC=khangvum,DC=com`                        |
  |        **Bind Password**         | The password of the account specified in **_Bind CN_**                |
  |           **Base DN**            | `DC=khangvum,DC=com`                                                  |

## 3. Synchronization & Verification

- Within the **_LDAP Source_** details page, click **_Sync LDAP source_**.
- Navigate to **Directory** > **Users** to confirm that **_domain users_** are **_imported_**.
