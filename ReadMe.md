# Demo.AstraDB.Airline

Welcome to AirStax!

Our fictional airline, AirStax, developed a passanger self service platform named Check-in, Experience, and Tickets or CHET for short. CHET is composed of a mobile application and website. It stores data in a Cassandra keyspace, which is hosted in Astra DB. We're using CHET to demonstrate how developers can use DataStax's database-as-a-service, [Astra DB](https://www.datastax.com/products/datastax-astra), to quickly build scalable and fault tolerant systems.

## Project

Use the content in this section to better understand the project's structure.

This project is composed of the following files and directories:

* _database_, DDL scripts for the application's database and location for seed data files.
* _docs_, documentation for the project.
* _flutter_app_, source and configuration files used to build the mobile application.
* _images_, images used in the application.
* _python_, scripts to create seed data.
* _react_, source and configuration files used to build the web application.
* _README_, the file you're currently reading.

## Installation

The material in this section guides users on CHET's installation and usage.

Before attempting to install or run CHET ensure the following prerequisites have been met:

1. Availability of an Active Astra DB subscription 
1. Python 3.x installed on the project's host
1. Node.js 14.x installed on the project's host
1. Flutter 2.x installed on the project's host
1. Apple Xcode installed on the project's host (MacOS only)
1. Android Studio installed on the project's host
1. The dsbulk utility installed on the project's host

Deploy the solution by executing the following steps:

---
### **Step-1:** Create Your Database and Keyspace

In this step, you'll be creating the database and keyspace used by the application.

1. Navigate to astra.datastax.com.
2. Login to the console.
3. Create a new database and keyspace by clicking the `Create Serverless Database` link and completing the `Create a Database` form.

**NOTE:** It will take a few moments for your new database to be provisioned. Wait for the database's state to turn to `Active` before proceeding to the next step.

---
### **Step-2:** Create Service Account

You will be creating the token used by the application to access the database in this step.

**NOTE:** Before executing the following steps, you'll need to login to the Astra console as you did in step-1.

1. Select **Organization Settings** from the organization drop down menu at the top left of the page.
2. Click the **Token Management** option on the left.
3. Select `Read/Write User` from the **Select Role** drop-down.
4. Click the **Generate Token** button.
5. Click the **Download Token Details** button.

Retain the token file you downloaded. You will use it in subsequent steps.

You can click the DataStax Astra logo at the top left of the screen to return to the Dashboard.

---
### **Step-3:** Generate Secure Bundle

The secure connection bundle allows you to securely connect to your Astra database using a native language driver like the cassandra-driver for Node.js or Python. In this step, you'll download the driver.

**NOTE:** Before executing the following steps, you'll need to login to the Astra console as you did in step-1.

1. From the Dashboard, click the name of your database.
2. Click the CQL **Connect** tab.
3. Click **Python** from the **Connect using a driver** list.
4.  Click the **Download Bundle** button.

Retain the connection bundle you downloaded. You will use it in subsequent steps.

---
### **Step-4:** Clone the Repository

If you haven't already, clone or download this repository.

---
### **Step-5:** Create Tables and Indexes

In this step, you'll be creating the tables used by CHET. 

**NOTE:** Before executing the following steps, you'll need to login to the Astra console as you did in step-1.

1. From the Dashboard, click the name of your database.
2. Click the CQL **Console** tab.
3. Navigate to the keyspace created in step-1 by issuing the following command (change `name-of-keyspace` to your keyspace name):

    ```cql
    use name-of-keyspace;
    ```
4. Paste the contents of the `create.cql` file from the `database` directory into the console and hit enter.

You can verify the tables were created successfully by issuing the command `describe tables;`.

---
### **Step-6:** Generate Data

In this step, you will generate the data files to be used in this exercise.

1. Navigate to the `Python` directory in this project.
2. Create a file named `credentials.py` in the directory with the following contents:

    ```python
    client_id = "Client ID"
    client_secret = "Client Secret"
    ```
    **NOTE:** Ensure you replace the `Client ID` and `Client Secret` with the values for your environment. You can retrieve these values from the file generated in step-2.

3. Install dependent modules:

    ```sh
    python3 -m pip install ./requirements.txt
    ```
    **NOTE:** Some users may prefer to install dependent modules in a separate environment. Please see documentation for `venv` to create and load a virtual environment to host any dependent modules.

4. Generate the data files by executing the `generate.py` file:

    ```sh
    python3 generate.py
    ```

Data files will be added to the `database/` directory, replacing any previous versions. Taken togther, they create a fully populated database with 4.1 million ticket records for 41,000 flights.

---
## **Step-7:** Load City Data and Flight Data using Console

1. Click the **Load Data** button at the top of the page.

    ![something](/docs/data_load_step_1.png)

2. Drag the `city.csv` file from the `/databases/` folder to the target under **Option 1: Upload your own dataset**

    ![something](/docs/data_load_step_2.png)

    **NOTE:** 

3. It will take a few minutes for the file to load. Look for the "Upload Successful" message before clicking the **Next** button to continuing.

4. Ensure the **Table Name** field is populated with "city"; this is the table the data is being imported into.

    ![something](/docs/data_load_step_3.png)

5. Add `name` as the partition key found under the **Keys and Keys and Clustering** section toward the bottom of the page.

    ![something](/docs/data_load_step_4.png)

6. Click the **Next** button.

7. Select the database name from the **Target Database** drop down.

    ![something](/docs/data_load_step_5.png)

8. Select the keyspace name from the **Target Keyspace** drop down.
9. Click the **Next** button.

At this point, you have loadd the city (departure and destination) data into the database. Now, you'll upload the flight data into the database.

10. Load the `flight_by_id.csv` file as you did with the `city.csv` data. Ensure the table name is `flight_by_id` and set the partition key to `id`.

11. Load the `flight_by_id.csv` file a second time as you did in the previous step. Ensure the table name is `flight_by_city` and set the partition key to `origin_city` and `destination_city` (in that order) and clustering key to `id`.

You conclude this step having executed three separate loads through the console. The `flight_by_id` and `flight_by_city` tables will have been created as part of this exercise.

---
## **Step-8:** Load Baggage and Ticket Data Using dsbulk

1. Launch a new shell (terminal) session.
2. Navigate to the project folder.

    ```sh
    cd /Demo.AstraDB.Airline
    ```

3. Set environment variables for the client id and secret.

    ```sh
    export ASTRA_CLIENT_ID=client-id
    export ASTRA_CLIENT_SECRET=client-secret
    ```

4. Replacing the `keyspace-name` and `path-to-secure-connection-bundle` with values from your environment, run the following commands:

    ```sh
    dsbulk load \
    -url ./database/baggage.csv \
    -k keyspace-name \
    -t baggage \
    -b "path-to-secure-connection-bundle" \
    -u $ASTRA_CLIENT_ID \
    -p $ASTRA_CLIENT_SECRET \
    -header true

    dsbulk load \
    -url ./database/ticket.csv \
    -k keyspace-name \
    -t ticket \
    -b "path-to-secure-connection-bundle" \
    -u $ASTRA_CLIENT_ID \
    -p $ASTRA_CLIENT_SECRET \
    -header true
    ```
    **NOTE:** You downloaded the secure connection bundle in step-3. You created the keyspace in step-1.

---
## **Step-9:** Add Credentials to Mobile Application

In this step, you will create a credential file for use by the mobile application.

1. Create a file named `credentials.dart` in the `/flutter_app/lib/util/` directory.
2. Replacing the values in angle brakcets (<>) with those from your environment, add the following content to the file:

```dart
class Credentials {
  static const String ASTRA_DB_ID = '<database-id>';
  static const String ASTRA_DB_REGION = '<database-region>';
  static const String ASTRA_DB_KEYSPACE = '<keyspace-name>';
  static const String APP_TOKEN =
      '<database-token>';
}
```

**NOTE:** You can obtain the database's id and region and keyspace name from the database Dashboard on the Astra console. Obtain the token from the file created in step-2.

---
## Running the Simulation

You run a project by starting the simulator then running the project. Flutter is smart enough to know a device simulator is running and connect to it. Navigate to the `flutter_app` directory. Run the following:

```sh
# Launch the iPhone simulator on MacOS
open -a Simulator

# Run your project
flutter run
```

---
## Dependencies

This sections provides some guidance on installing dependencies.

### Installing dsbulk

You can find instructions on installing dsbulk from the [DataStax Bulk Loader](https://docs.datastax.com/en/astra/docs/loading-and-unloading-data-with-datastax-bulk-loader.html) article on [docs.datastax.com](https://docs.datastax.com/).

### Subscribe to Astra and Setup DB

There are several ways to subscribe to Astra. Possibly the simplist is to navigate to astra.datastax.com, click the Sign-Up link, and complete the registration form. Subscribers don't need to credit card or other payment information, and they can register with a Google or Github account.

### Install Flutter, XCode, and Android Studio

The following instructions guide you on installing Flutter and dependent software. For detailed instructions, see the documentation for that product.

**Step-1:** Download and install Flutter.

```sh
flutter_package_name="flutter_macos_2.2.3-stable.zip"

curl -LO "https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/${flutter_package_name}" && unzip "./${flutter_package_name}"
mkdir -p ~/bin/flutter
mv ./flutter ~/bin/ && rm "${flutter_package_name}"
echo 'export PATH=$PATH:$HOME/bin/flutter/bin' >> ~/.bashrc
source ~/.bashrc
```

**Step-2:** (MacOS Only) Download and Install XCode from the Apple App Store. This takes a bit.
**Step-3:** Configure XCode for use:

```sh
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

**Step-3:** Download and Install Android Studio.

1. From your web browser, navigate to "https://developer.android.com/" and download Android studio.
2. Download, install, and configure Android Studio. On MacOS, you drag and drop the application into the Applications folder. After installation, launch 
3. Launch Android Studio. A wizard starts on first launch. The wizard will include an "SDK Components Setup". Select the following:

* Android SDK
* API 30: Android 11.0
* Performace (Intel HAXM) - if you can
* Android Virtual Device

NOTE: You can install additional Android SDK's from the SDK Manager, under the "Configure" menu on the startup screen. 

**Step-4:** Verify your Flutter installation by running Flutter Doctor:

```
flutter doctor
```

You should see all  green checkmarks. You want Flutter Doctor to return all green checkmarks. However, it might not. If the doctor tells you to enable Android licenses, update components, or install additional software. Do what the doctor tells you.

**NOTE:** You can accept the licenses with the following command:

```sh
flutter doctor --android-licenses
```

## License

[GPL v3.0](https://www.gnu.org/licenses/gpl-3.0.txt)
