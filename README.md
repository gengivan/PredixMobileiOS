##Predix Mobile iOS Container sample app

This project is the sample reference application for the Predix Mobile Container on the iOS platform.

Use the Predix Mobile SDK to develop a Predix Mobile Application Container and the Predix Mobile applications that run in that container. A Mobile Application Container is a native application that includes the Predix Mobile Client Core Services framework that will load, display and run the Predix Mobile applications that you build.

The Predix Mobile SDK for iOS includes the source, SDK framework and Xcode project that you use to build a Predix Mobile Application Container. In most cases the Predix Mobile Application Container has the functionality that applications need, but on the iOS platform an application development team can extend the Core Serves Framework with additional RESTful services.

##Getting Started
### Prerequisites
It is assumed you already have a Predix Mobile service instance, have installed the Predix Mobile command line tool, and have performed all tasks in these topics:
* [Get Started with the Mobile Service and Mobile SDK] (https://www.predix.io/docs#rae4EfJ6) 
* [Running the Predix Mobile Sample App] (https://www.predix.io/docs#EGUzWwcC)
* [Creating a Mobile Hello World Webapp] (https://www.predix.io/docs#DrBWuHkl)

It is also assumed you're running on a Mac, with the latest version of XCode installed.

A basic understanding of how to use XCode is also assumed. For help with XCode consult Apple's documentation.

### Step 1 - Clone Repo

Clone the repo to your Mac.

### Step 2 - Configuration

From the command line, in the cloned directory, run the script `set-pm-host.sh`.

This will configure the Predix Mobile Container to your instance of Predix Mobile service backend.

### Step 3 - Open the project file

Open the `PredixMobileReferenceApp.xcodeproj` file in XCode.

Written in Swift, this implementation is purposefully simple. 

### Step 4 - Validate the Predix Mobile App

As one of the prerequistes, you defined a Predix Mobile App using the command line tool. The name and version of that pmapp is configured in the `info.plist` of the Predix Mobile Container.

In XCode, find the `Info.plist` file. The plist keys `pmapp_name` and `pmapp_version` should match the values used in your `app.json` file you defined.

By default these settings are:

    pmapp_name: Sample1
    pmapp_version:  1.0

### Step 5 - Run the project

Run the project in XCode. The Predix Mobile Container should start in the simulator, and you should be presented with the Predix login screen.


## TroubleShooting:

### Enabling increased logging:

Logging by default is set at "Info" level. There are two more informative levels that can give you more information for debugging problems: Debug, and Trace.

To increase the logging level, in the iOS Simulator, go to the Settings app, scroll down to the PredixUp application, and tap on the Logging level.

You must have run the container application at least once in order for the PredixUp App to appear in Settings.

### I see a sad looking kitten:

The sad kitty is this sample app's serious error page. While whimsical, it lets you know that something is configured incorrectly, or some other error prevented the app from starting. Use the error message on this page, and the console logs in XCode to determine the problem.

### Sad Kitty says: "Authentication failed" but I never saw the authentication page.

Reviewing the logs you will see various network error messages, and messages indicating you cannot connect to the backend.

First, ensure your Mac is online. Then, review the Server setting in the Settings app. It would appear your server host setting is not correct. Either a problem occured in Step 2, or the setting was changed so the system could never load the initial login page.

### Sad Kitty says: "Authentication failed" after I correctly entered my username and password

Reviewing the logs you may see a line like:

    Online authentication completed successfully

Then immediately afterwards:

     Error requesting user data:

And other networking related error messages.

In this case you successfully logged in, but then the system was unable to download your user information. Either due to a suddenly occuring network interuption, or some problem with the backend services.

### Sad Kitty says: "Unable to determine initial startup PredixMobile App"

This will occur if the pmapp_name, and pmapp_version configured in Step 4 is not found. Confirm that these settings match what was in your app.json file defined using the command line (pm tool) "define" command.




