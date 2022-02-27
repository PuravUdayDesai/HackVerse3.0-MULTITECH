# HackVerse3.0-MULTITECH

## Title
Come Post: An Initiative to reduce Food Wastage

## Description
It is more common in the current scenario to throw leftover food in the trash, particularly from hotels and restaurants, which causes mass food wastage, thereby increasing the size of dump yards and potentially leading to more diseases. There is waste generated in households as well, but collectively it becomes a huge amount and this waste is discarded directly in dump yards.With leftover food, we can generate fertilizer, biogas, and bio enzymes and provide these by-products to farmers at a reduced cost. This in turn decreases farmers' manure cost, which enables them to produce organic vegetables and fruits at a lower cost, and we can supply these to consumers like hostels, restaurants, and households at an even lower cost than the market price. By utilizing this supply-chain model, farmers and consumers can obtain manure and vegetables at a discount, while also reducing the amount of waste generated at dump yards.

## Tech stack
![image](https://user-images.githubusercontent.com/44437936/155870061-f822db16-966d-4408-8d30-a7fd93cf84d9.png)

## Installation Steps
### Backend
1. Clone github repository
2. Create a Spring Boot Starter Project
3. Run as Spring Boot Application
### Frontend
1. Clone/Download the mobile branch repository.
2. Run `flutter pub get` to get all the dependencies
3. Now, app is ready to run using `flutter run`

## Libraries and dependencies
### Backend (pom.xml)
```xml
<dependency>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-starter-web</artifactId>
</dependency>
```
```xml
<dependency>
	<groupId>org.postgresql</groupId>
	<artifactId>postgresql</artifactId>
	<scope>runtime</scope>
</dependency>
```
```xml		
<dependency>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-starter-test</artifactId>
	<scope>test</scope>
</dependency>
```
```xml
<dependency>
	<groupId>joda-time</groupId>
	<artifactId>joda-time</artifactId>
	<version>2.10.13</version>
</dependency>
```
```xml
<dependency>
	<groupId>javax.mail</groupId>
	<artifactId>mail</artifactId>
	<version>1.4</version>
</dependency>
```
```xml		
<dependency>
	<groupId>javax.validation</groupId>
	<artifactId>validation-api</artifactId>
	<version>2.0.1.Final</version>
</dependency>
```
### Frontend
1. Google Maps API
2. _flutter_localizations_ dependency for internationalization 
3. Other flutter packages as per _pubspec.yaml_

## Declaration of Previous Work
### Before
1. Project Planning and Ideation.
2. Project Flow Structuring.
3. Database Design.
4. Implemented 3 user modules (composter, supplier, farmer) with basic CRUD in Back-end.
5. Implemeted authentication of 3 user modules in front-end.

### In 24-Hours
1. Restructed Database design and made it normalized.
2. Mapped independent 3 user modules and established a connection between them.
3. Added basic statistics and analysis in Front-end for composter and farmer.
4. Google Maps API in Front-end.
5. Internationalization with 2 languages (Hindi, Gujarati)
6. Made front-end code compatible with latest version of Flutter.
7. Developed and Integrated end-points.
8. Restructed backend code and added search and filtering options.

## Documentation

Backend API documentation: [https://documenter.getpostman.com/view/13664185/UVkqqZkT#cbe4a2bf-a801-42ee-bbca-378915e328a8](https://documenter.getpostman.com/view/13664185/UVkqqZkT#cbe4a2bf-a801-42ee-bbca-378915e328a8)
