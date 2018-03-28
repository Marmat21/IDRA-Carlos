# IDRA


This repository contains the packages for IDRA, an out-of-place debugger for non-stoppable applications.

It contains three packages:
1. **IDRA**: provides the necessary infrastructure to open a remote debugger with another image, whose failing stack will be sent to the debugger image, that can than debug remotely without affecting the work of the client.
2. **IDRA-MasterWorkerArchitecture**: provides a small framework for master-worker execution
3. **IDRA-TestRunner**: provides a concrete implementation of the master-worker architecture for out-of-place debugging of test running. 

# Dependencies

*IDRA* does not have external dependencies, except packages that can be found in Pharo 7.0.

On the other hand, **IDRA-TestRunner** depends on **IDRA-MasterWorkerArchitecture**.
**IDRA-MasterWorkerArchitecture** uses a package called *taskIt* to schedule tasks.

If you wish to load such packages, you need to solve the *taskIt* dependency, install the *taskIt* passage with the following command.

``` 
  Metacello new
  baseline: 'TaskIt';
  repository: 'github://sbragagnolo/taskit';
  load.
```

# Setup

In order to correctly work, you need two images with the same code base.
Once you are sure to have that, you have to detect which is your debugger image (only one allowed), and which is your debugged/client image (more than one are allowed).

In order to setup an image with a complete Debugger (with changes handler included) in **debug mode** execute the following in your playground:

```
  debuggerWithHandler := DebuggerWithChangesHandler setupAsDebuggerOnPort: aPortNumber.
```

Please don't get rid of the *debuggerWithHandler* variable because it will be useful to commit debugger changes to workers.
Choose aPortNumber and keep it in mind

On your workers images, to setup the debugger in **client mode**, execute the following:
```
debuggerWithHandlerMonitor := DebuggerWithChangesHandler setupAsDebuggerMonitorOnUrl: aUrl port: aPort listeningChangesUrl: httpUrlOfTheClient port: changesPort
```
substitute *aUrl* with the url of your image (might be localhost, might be your local address. Start it with 'http://') and *aPort* with the port you selected in the debugger setting up process.

*httpUrlOfTheClient* indicates the (public of not) url of the client, that should be visible to the master in order to send changes.
Choose a *changesPort* and keep it in mind for the next process.

On your debugger image you should get a message that the connection is correctly setup.

Last step is to connect the Debugger image to the Client image.
To do so, execute the following in your debugger image:
```
  debuggerWithHandler connectToSendChangesToClientURL: aUrl port: changesPort.
```
Use for *aUrl* the location of the Client image (with 'http://' prefix), and as *changesPort* the port that you used to initialize the client with.

To enable an *IDRA Monitor* to detect all the exceptions of your image (and not only the custom *IDRAHandlableError*) you should execute 
```
IDRAMonitor getInstance debugAll: true.
```

Finally, 
to send changes at some point to the connected clients, you should use the following in your Debugger image:
```
debuggerWithHandler changesHandler serializeChanges.
```

Enjoy The debugger!
