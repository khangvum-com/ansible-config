# Node.js Web Page Deployment on IIS

A **_web application deployment_** process for Windows, leveraging **_Internet Information Services_** (**_IIS_**) as a **_reverse proxy_** to host modern web **_React front ends_** (_e.g.,_ Vite), **_Node.js back ends_** (_e.g.,_ Express), and **_Supabase_**.

## 1. Environment Preparation

On `KVM-WEB01`:

- Install **_[Node.js (LTS)](https://nodejs.org/en/download)_**.
- Install **_[URL Rewrite Module](https://www.iis.net/downloads/microsoft/url-rewrite)_**.
- Install **_[Application Request Routing (ARR)](https://www.iis.net/downloads/microsoft/application-request-routing)_**.
- **_Configure ARR_**:
  - Open **_Internet Information Services (IIS) Manager_** (`inetmgr`) > **KVM-WEB01** > **Application Request Routing Cache** > **Server Proxy Settings...**.
  - Check **_Enable proxy_** and click **_Apply_**.

## 2. Process Management (PM2) Installation & Configuration

- Install **_[PM2](https://www.npmjs.com/package/pm2)_** globally to manage the application lifecycle and ensure the Node process remains active:

  ```powershell
  npm install pm2 -g
  ```

- Start the application from the **_project root_** (_e.g.,_ `C:\inetpub\wwwroot\itinder.khangvum.com`):

  ```powershell
  pm2 start server.js --name "itinder.khangvum.com"
  ```

- Install and configure the **_Windows service helper_** to ensure the application **_starts automatically on boot_**:

  ```powershell
  npm install pm2-windows-service -g
  pm2-service-install
  pm2 save
  ```

> [!TIP]
>
> - When running `pm2-service-install`, set `PM2_HOME` to **_`C:\pm2`_** (or a similar root-level directory).
> - This allows for **_system-wide access_**, ensuring the service can manage the processes **_regardless_** of **_which user_** is **_logged into the server_**.

## 3. Front End Build (React)

- **_Compile_** the **_React front end_** inside the `/client` directory (this project uses **_Vite_**):

  ```powershell
  npx vite build & xcopy /hiev dist\* ..\server\public\ /Y
  ```

> [!NOTE]
> This command **_compiles the React assets_** and **_synchronizes_** the `/client/dist` contents with the `/server/public` directory.

- **_Copy_** the content of the **_`/server` folder_** into **_`C:\inetpub\wwwroot\itinder.khangvum.com`_** on **_`KVM-WEB01`_**.
- Open **_Internet Information Services (IIS) Manager_** (`inetmgr`), right-click **Sites** > **Add Website...**:

  |     Property      | Value                                                                                           |
  | :---------------: | ----------------------------------------------------------------------------------------------- |
  |   **Site name**   | `ITinder`                                                                                       |
  | **Physical path** | `C:\inetpub\wwwroot\itinder.khangvum.com`                                                       |
  |    **Binding**    | Type: `http`<br>IP address: `All Unassigned`<br>Port: `80`<br>Host name: `itinder.khangvum.com` |

## 4. IIS Reverse Proxy Configuration

To allow IIS to server as the **_gateway_** for the Node.js application, a **_`web.config`_** file must be configured within the site's **_physical path_** (_e.g.,_ `C:\inetpub\wwwroot\itinder.khangvum.com`) to direct IIS to handle **_client-side routing_** for the React front end while proxying backend requests to the Node.js process:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <system.webServer>
        <webSocket enabled="false" />
        <rewrite>
            <rules>
                <rule name="SocketIO" stopProcessing="true">
                    <match url="^socket.io/(.*)" />
                    <action type="Rewrite" url="http://localhost:5000/socket.io/{R:1}" />
                </rule>

                <rule name="NodeProxy" stopProcessing="true">
                    <match url="(.*)" />
                    <conditions>
                        <add input="{REQUEST_FILENAME}" matchType="IsFile" negate="true" />
                    </conditions>
                    <action type="Rewrite" url="http://localhost:5000/{R:1}" />
                </rule>
            </rules>
        </rewrite>
    </system.webServer>
</configuration>
```

## 5. DNS Setup

- On the **_DNS server_** (_e.g.,_ **_`KVM-DC01`_**), open **_DNS Manager_** (`dnsmgmt.msc`).
- Add a new **_A record_**:
  - Navigate to **Forward Lookup Zone** > the domain (_e.g.,_ `khangvum.com`).
  - Right click > **New Host (A or AAAA)...**:

    |    Property    | Value                                |
    | :------------: | ------------------------------------ |
    |    **Name**    | `itinder`                            |
    | **IP address** | The IP of the IIS Server `KVM-WEB01` |

## 6. Site Access Test

Once everything is configured, browse to `http://itinder.khangvum.com`.
