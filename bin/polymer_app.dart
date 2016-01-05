/**
 * Created by lejard_h on 04/01/16.
 */

import 'dart:io' as io;
import 'package:cupid/cupid.dart';
import 'package:polymer_app/utils.dart';
import "package:polymer_app/polymer_app_manager.dart";
import "package:polymer_app/polymer_app_services.dart";
import "package:polymer_app/polymer_app_models.dart";
import "package:polymer_app/polymer_app_behaviors.dart";
import "package:polymer_app/polymer_app_elements.dart";
import "package:polymer_app/polymer_app_routes.dart";
import "dart:convert";
import "dart:async";

const default_root_directory = "./";

Question askName = const Question('Name of your application:', type: String);
Question askRootDirectory = const Question(
    'Localisation of your application (default: "$default_root_directory"):',
    type: String);
Question askMaterial = const Question(
    'Do you want material design application (Y/n):',
    type: String);

main(List<String> args, __) {
  cupid(new PolymerApp(), args, __);
}

class PolymerApp extends Program {
  io.Directory outputFolder;
  io.File configFile;
  PolymerAppManager manager;
  String appName;
  String rootDirectoryPath;
  io.Process servingProcess;

  PolymerApp();
  setUp() {
    InputDevice.prompt = new Output('<cyan>polymer_app ></cyan> ');
    _getOutputFodler("./");
    _getConfigFile();
    if (configFile.existsSync()) {
      print("'polymer_app.json' config found.");
    }
  }

  tearDown() {
    if (servingProcess != null) {
      servingProcess.kill();
      this.print("Stop serve application");
    }
  }

  @Command('Create new polymer_app route.')
  new_route(
      {@Option('Your route name') String name,
      @Option('Your route path') String path}) async {
    if (name == null) {
      Question askBehaviorName =
          const Question('Name of your route:', type: String);
      name = await ask(askBehaviorName);
      if (name?.isEmpty) {
        printDanger("Please enter a valid route name");
        exit();
      }
    }
    if (path == null) {
      Question askRoutePath =
          const Question('Path of your route:', type: String);
      path = await ask(askRoutePath);
      if (path?.isEmpty) {
        printDanger("Please enter a valid route path");
        exit();
      }
    }
    String routesDirectory = "./";
    _getOutputFodler("./");
    _getConfigFile();

    if (manager != null) {
      routesDirectory = manager.routes.libraryPath;
    } else {
      Question askElementsDirectory = new Question(
          'Route directory path (default: $routesDirectory):',
          type: String);
      String path = await ask(askElementsDirectory);
      if (path.isNotEmpty) {
        routesDirectory = path;
      }
    }

    print("Creating '${green(name)}' route");

    RoutesManager routes =
        manager?.routes ?? new RoutesManager(name, routesDirectory);

    routes.createRoute(name, path);
    if (manager != null) {
      routes.addToLibrary("$name-route");
    }
    exit();
  }

  @Command('Create new polymer_app model.')
  new_model({@Option('Your model name') String name}) async {
    if (name == null) {
      Question askBehaviorName =
          const Question('Name of your model:', type: String);
      name = await ask(askBehaviorName);
      if (name?.isEmpty) {
        printDanger("Please enter a valid model name");
        exit();
      }
    }
    String modelsDirectoryPath = "./";
    _getOutputFodler("./");
    _getConfigFile();

    if (manager != null) {
      modelsDirectoryPath = manager.models.libraryPath;
    } else {
      Question askModelsDirectory = new Question(
          'Model directory path (default: $modelsDirectoryPath):',
          type: String);
      String path = await ask(askModelsDirectory);
      if (path.isNotEmpty) {
        modelsDirectoryPath = modelsDirectoryPath;
      }
    }

    print("Creating '${green(name)}' model");
    ModelsManager models =
        manager?.models ?? new ModelsManager(name, modelsDirectoryPath);

    models.createModel(name);
    if (manager != null) {
      models.addToLibrary("$name\_model");
    }
    exit();
  }

  @Command('Create new polymer_app service.')
  new_service({@Option('Your service name') String name}) async {
    if (name == null) {
      Question askServiceName =
          const Question('Name of your service:', type: String);
      name = await ask(askServiceName);
      if (name?.isEmpty) {
        printDanger("Please enter a valid service name");
        exit();
      }
    }
    String serviceDirectory = "./";
    _getOutputFodler("./");
    _getConfigFile();

    if (manager != null) {
      serviceDirectory = manager.services.libraryPath;
    } else {
      Question askServiceDirectory = new Question(
          'Service directory path (default: $serviceDirectory):',
          type: String);
      String path = await ask(askServiceDirectory);
      if (path.isNotEmpty) {
        serviceDirectory = path;
      }
    }

    printInfo("Creating '${green(name)}' service");

    ServicesManager services =
        manager?.services ?? new ServicesManager(name, serviceDirectory);

    services.createService(name);
    if (manager != null) {
      services.addToLibrary("$name\_service");
    }
    exit();
  }

  @Command('Create new polymer behavior.')
  new_behavior({@Option('Your behavior name') String name}) async {
    if (name == null) {
      Question askBehaviorName =
          const Question('Name of your behavior:', type: String);
      name = await ask(askBehaviorName);
      if (name?.isEmpty) {
        printDanger("Please enter a valid behavior name");
        exit();
      }
    }
    String behaviorsDirectory = "./";
    _getOutputFodler("./");
    _getConfigFile();

    if (manager != null) {
      behaviorsDirectory = manager.behaviors.libraryPath;
    } else {
      Question askBehaviorsDirectory = new Question(
          'Behavior directory path (default: $behaviorsDirectory):',
          type: String);
      String path = await ask(askBehaviorsDirectory);
      if (path.isNotEmpty) {
        behaviorsDirectory = path;
      }
    }
    BehaviorsManager behaviors =
        manager?.behaviors ?? new BehaviorsManager(name, behaviorsDirectory);

    print("Creating '${green(name)}' behavior");
    behaviors.createBehavior(name);
    if (manager != null) {
      behaviors.addToLibrary("$name\_behavior");
    }
    exit();
  }

  @Command('Create new polymer element.')
  new_element({@Option('Your element name') String name}) async {
    if (name == null) {
      Question askElementName =
          const Question('Name of your element:', type: String);
      name = await ask(askElementName);
      if (name?.isEmpty || toLispCase(name).split("-").length < 2) {
        printDanger("Please enter a valid element name");
        exit();
      }
    }
    String elementsDirectory = "./";
    _getOutputFodler("./");
    _getConfigFile();

    if (manager != null) {
      elementsDirectory = manager.elements.libraryPath;
    } else {
      Question askElementsDirectory = new Question(
          'Element directory path (default: $elementsDirectory):',
          type: String);
      String path = await ask(askElementsDirectory);
      if (path.isNotEmpty) {
        elementsDirectory = path;
      }
      exit();
    }

    ElementsManager elements =
        manager?.elements ?? new ElementsManager(name, elementsDirectory);

    print("Creating '${green(name)}' element");
    elements.createElement(name);
    if (manager != null) {
      elements.addToLibrary(name);
    }
  }

  @Command('Create new polymer_app config.')
  new_config(
      {@Option('Your application name') String name,
      @Option('The output folder of your application')
      String configOutputFolderPath: "./"}) async {
    rootDirectoryPath = configOutputFolderPath;
    appName = name;
    if (appName == null) {
      appName = await _askAppName();
    }
    _getOutputFodler(rootDirectoryPath);
    io.File config = writeInFile(
        "${outputFolder.resolveSymbolicLinksSync()}/polymer_app.json",
        getDefaultJsonConfig(appName));
    exit();
    return config;
  }

  @Command('Create new polymer application.')
  new_application(
      {@Option('Your application name') String name,
      @Option('The output folder of your application') String outputFolderPath,
      @Option('True if you want Material Design')
      bool isMaterial: true}) async {
    appName = name;
    if (appName == null) {
      appName = await _askAppName();
    }
    rootDirectoryPath = outputFolderPath;
    if (rootDirectoryPath == null) {
      rootDirectoryPath = await _askRootDirectory();
    }
    _getOutputFodler(rootDirectoryPath);
    _getConfigFile();
    printInfo("Creating '${green(appName)}' application");
    writeInFile("${outputFolder.resolveSymbolicLinksSync()}/polymer_app.json",
        getDefaultJsonConfig(appName));
    _getConfigFile();
    manager.createApplication(material: isMaterial);
    this.print("cd $rootDirectoryPath; pub get; pub serve");
    exit();
  }

  _getOutputFodler(String outputFolderPath) {
    if (!outputFolderPath.startsWith("./") &&
        !outputFolderPath.startsWith("/")) {
      outputFolderPath = "./$outputFolderPath";
    }
    outputFolder = new io.Directory(outputFolderPath);
    if (!outputFolder.existsSync()) {
      outputFolder.createSync(recursive: true);
    }
  }

  _getConfigFile() {
    configFile = new io.File(
        "${outputFolder?.resolveSymbolicLinksSync()}/polymer_app.json");

    if (configFile.existsSync()) {
      manager = new PolymerAppManager(configFile.resolveSymbolicLinksSync(),
          outputFolder.resolveSymbolicLinksSync());
    }
  }

  _askAppName() async {
    String appName = await ask(askName);
    if (appName?.isEmpty || appName == "test") {
      printDanger("Please enter a valid application name.");
      exit();
    }
    return appName;
  }

  _askRootDirectory() async {
    String rootDirectory = await ask(askRootDirectory);
    if (rootDirectory?.isEmpty) {
      rootDirectory = default_root_directory;
    }
    return rootDirectory;
  }

  Future _run(String executable, List<String> arguments,
      {String workingDirectory: "./", bool showOutput: false}) async {
    final io.Process process = await io.Process
        .start(executable, arguments, workingDirectory: workingDirectory);
    if (showOutput) {
      process.stdout.map(UTF8.decode).listen(this.print);
      process.stderr.map(UTF8.decode).listen(this.printDanger);
    }
    return process;
  }
}

String getDefaultJsonConfig(String appName, [String path = "lib"]) => '{'
    '"name": "$appName",'
    '"library_path": "$path",'
    '"web_path": "web",'
    '"elements_path": "elements",'
    '"services_path": "services",'
    '"behaviors_path": "behaviors",'
    '"models_path":  "models",'
    '"routes_path": "routes"'
    '}';
