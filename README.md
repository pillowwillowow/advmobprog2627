# arellano_advmobprog

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# Lab Activity 2: Discussion

This activity follows the Model–Service–Screen architecture, which separates the application's data, business logic, and user interface into different layers. This design makes the application easier to understand, maintain, and expand.

The Model represents the structure of the data received from the API. It defines the attributes of an object and provides methods to convert JSON data into Dart objects and vice versa. Instead of working directly with raw JSON, the application uses model objects, making the code cleaner and more organized.

The Service layer is responsible for communicating with the API. It sends HTTP requests to the API endpoint, receives the server's response, and converts the JSON response into model objects. The service acts as the bridge between the application and the external data source, keeping networking code separate from the user interface.

The Screen serves as the presentation layer. It calls the appropriate service methods to request data from the API. Once the service returns the model objects, the screen updates its state and displays the information to the user using Flutter widgets such as `ListView`, `Card`, or `GridView`. This separation ensures that the UI focuses only on presenting data rather than handling API communication.

The interaction between these components follows this sequence:

1. The user opens the screen or performs an action.
2. The screen calls a method from the service layer.
3. The service sends an HTTP request to the API endpoint.
4. The API returns a JSON response.
5. The service converts the JSON into model objects.
6. The model objects are returned to the screen.
7. The screen rebuilds the UI and displays the retrieved data.

This activity introduces a layered design pattern based on the Model–Service–Screen architecture, which is commonly used in Flutter applications. By separating data models, API services, and UI screens into different files, the application becomes more modular, reusable, and easier to debug. Future enhancements, such as adding new API endpoints or modifying the user interface, can be implemented with minimal changes to the other layers, resulting in a more scalable and maintainable application.

