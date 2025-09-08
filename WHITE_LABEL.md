# White Label Refactor

The goal of this work is to externalise reusable pieces of dart/flutter that will allow me to produce a build for any client simply by adjusting the base URL.

All of the data and functionality in the app will be determined by that single entrypoint.

There will be a desire to change the available features on a per-app basis, so each UI component must be able to work independently of another, unless explicitly related.

## Components

All components would receive a base URL.
In a debug build, this should be configurable in the OS level settings for the App.

- News - the news system is based on RSS feed.
  - The URL to the RSS will be required input - absolute path relative to base url
  - The number of items to show on the initial page should default to 10, allow customisation per-app.
  - The number of items to reveal in infinite scroll should default to 5, allow customisation per-app.
- Clubs - the clubs system is based on REST data.
  - There will be a list of clubs obtained from API_BASE/v1/clubs/
  - Default visibility should be those with status=active
  - Per app override to allow showing status=inactive
  - Per app override to allow showing status=hidden
  - Per app override to allow exclusion by slug (regardless of status from API data)
  - Mapping of slug to image
- Fixtures & Results - the fixture/result system is based on REST data.
  - There will be a list of competitions obtained from API_BASE/v1/competitions/
  - Several layers push to a stack here:
    - Competition
    - Season
    - Division
  - Must be possible to start at any level (ie. direct into a Competition, Season, or Division) - per-app configurable
  - Per app override to allow exclusion by slug of competition, competition+season, competition+season+slug
- Favourites - coupled to fixtures and results
  - List of user shortcuts to go direct to any depth of Competition/Season/Division and even Team (within a Division)
  - Must clear the stack of the fixtures and results component.

## Navigation

Default would be that each component is represented by a navigation bar at the bottom of the screen.
- each module has a default name and icon - both must be able to be overridden

Switching from one component to another should not impact the state of another:
- unless there are coupled components, and one causes a state change in the other (ie. click on a favourite to jump to specific event)

## Other factors

The application will start with a splash screen.
- The logo of which should be an embedded asset.

Colour scheme should be determined from a per-app configuration structure.
- usually will be a single default colour for backgrounds
- some app builds may require different colours per component (ie. news = white, fixtures = green, favourites = blue)

## Use libraries to improve quality and testability

I've identified several libraries I'd like to explore for inclusion and refactor to use.

Knowing information about a device or connectivity seems to be useful - we can enable or disable features we know not to work on certain platforms, or pause data updates if we know the device is offline.
- [ ] `connectivity_plus` - Flutter plugin for discovering the state of the network (WiFi & mobile/cellular) connectivity on Android and iOS.
- [ ] `device_info_plus` - Flutter plugin providing detailed information about the device (make, model, etc.), and Android or iOS version the app is running on.

Using standard system API's for simple KV data is appealing, we can avoid keeping this in our app and externalise it to the device.
- [ ] `shared_preferences` - plugin for reading and writing simple key-value pairs. Wraps NSUserDefaults on iOS and SharedPreferences on Android.

This sounds like a nice design pattern, separation of the business logic from the UI - I would like to see if this makes sens.
- [ ] `bloc` and `flutter_bloc` - BLoC is a software pattern, particularly in Flutter mobile development, that separates the user interface (UI) from the core business logic and application state, improving code organization, testability, and maintainability.

The various colour scheming I mentioned _may_ be possible with this library? Not sure if it is designed to allow users to choose, or developers to choose?
- [ ] `flex_color_scheme` - package to use and make beautiful Material design based themes.

We connect to remote services for all our app data, this looks like a nice library for dealing with obtaining that data asynchronously, and possibly for scheduled background updates.
- [ ] `riverpod` - A reactive caching and data-binding framework. Riverpod makes working with asynchronous code a breeze.

A feature we don't yet have but I was thinking of was allowing for notifications to be sent to remind the device owner of an upcoming match starting.
- [ ] `flutter_local_notifications` - cross platform plugin for displaying and scheduling local notifications for Flutter applications with the ability to customise for each platform.
