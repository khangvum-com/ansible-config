# .NET Web Page Deployment on IIS

A **_web application deployment_** process for Windows, leveraging **_Internet Information Services_** (**_IIS_**) to host modern web **_front ends_** (_e.g.,_ Vue) with **_.NET APIs_** and **_SQL Server back ends_**.

## 1. SQL Server Setup

- Install **_[SQL Server 2022 Developer Edition](https://www.microsoft.com/en-us/sql-server/sql-server-downloads)_** on **_`KVM-DB01`_**.
- During setup, add these accounts to **_sysadmin_** (**_SAD_**):

  |         Account          | Description                               |
  | :----------------------: | ----------------------------------------- |
  | `KVM-DB01\Administrator` | Local admin on the SQL Server host        |
  | `KHANGVUM\Administrator` | Domain admin                              |
  |     `Domain Admins`      | Security group (optional but recommended) |

> [!TIP]
> **Optional**: Install **_[SQL Server Management Studio (SSMS)](https://learn.microsoft.com/en-us/ssms/install/install)_**.

- Create the application database (_e.g.,_ `INFO3181Casestudy`).
- **_Expose SQL Server_** for remote access by allowing inbound traffic on **_port 1433_**:

  ```powershell
  New-NetFirewallRule -Name "SQL-Server-TCP-1433" -DisplayName "SQL Server TCP 1433" -Direction Inbound -Protocol TCP -LocalPort 1433 -Action Allow
  ```

## 2. Front End Build (Vue)

- **_Compile_** the **_Vue front end_** (this project uses **_Vue with Quasar Framework_**):

  ```powershell
  npx quasar build
  ```

- Copy the **_compiled output_** (the **_content_** of the **_`dist` folder_**) into the **_C# project’s `wwwroot`_** folder.

## 3. Back End Build (.NET API)

- Update the `appsettings.json` **_connection string_**:

  ```json
  "ConnectionStrings": {
    "DefaultConnection": "Server=KVM-DB01.khangvum.com;Database=INFO3181Casestudy;Trusted_Connection=True;TrustServerCertificate=True;"
  }
  ```

- **_Publish_** the .NET app:

  ```powershell
  dotnet publish -c Release -f net8.0 -o ./publish
  ```

## 4. IIS Deployment

- **_Copy_** the content of **_`publish` folder_** into **_`C:\inetpub\wwwroot\info3181casestudy.khangvum.com`_** on **_`KVM-WEB01`_**.
- Open **_Internet Information Services (IIS) Manager_** (`inetmgr`), right-click **Sites** > **Add Website...**:

  |     Property      | Value                                                                                                     |
  | :---------------: | --------------------------------------------------------------------------------------------------------- |
  |   **Site name**   | `INFO-3181 Casestudy`                                                                                     |
  | **Physical path** | `C:\inetpub\wwwroot\info3181casestudy.khangvum.com`                                                       |
  |    **Binding**    | Type: `http`<br>IP address: `All Unassigned`<br>Port: `80`<br>Host name: `info3181casestudy.khangvum.com` |

- Configure **_application pool_**:
  - In **IIS Manager** > **Application Pools**, locate the site’s pool (_e.g.,_ `info3181casestudy`).
  - Right-click the site's pool > **Advanced Settings...**.
  - Under **Process Model** > **Identity**, set to **Custom account**, and add the domain administrator (_e.g.,_ `KHANGVUM\Administrator`)
  - Recycle the pool.

- Install **_[Hosting Bundle](https://learn.microsoft.com/en-us/aspnet/core/host-and-deploy/iis/hosting-bundle)_**.

## 5. DNS Setup

- On the **_DNS server_** (_e.g.,_ **_`KVM-DC01`_**), open **_DNS Manager_** (`dnsmgmt.msc`).
- Add a new **_A record_**:
  - Navigate to **Forward Lookup Zone** > the domain (_e.g.,_ `khangvum.com`).
  - Right click > **New Host (A or AAAA)...**:

    |    Property    | Value                                |
    | :------------: | ------------------------------------ |
    |    **Name**    | `info3181casestudy`                  |
    | **IP address** | The IP of the IIS Server `KVM-WEB01` |

> [!NOTE]
> **Optional**: Enable **Create associated pointer (PTR) record**.

- Verify DNS resolution:

  ```powershell
  nslookup info3181casestudy.khangvum.com
  ```

## 6. Site Access Test

Once everything is configured, browse to `http://info3181casestudy.khangvum.com`.

> [!CAUTION]
> Instead of running the application pool under a domain admin like `KHANGVUM\Administrator`, use a **_dedicated service account_** for **_security_**:
>
> - Create a **_service account_** in **_Active Directory_**.
> - **_Grant_** this account **_db_owner_** on your **_application database_**.
> - Configure **_IIS Application Pool Identity_** to use this account.
>
> This keeps the environment more **_secure_** while still **_allowing_** the application to **_connect_** to **_SQL Server_**.
