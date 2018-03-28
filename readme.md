I represent a Debugger with Changes Handler.

You can use me to start an IDRA Debugger connected to an IDRA Changes Handler int two modes:
1. debugger monitor mode to listen for exceptions.
2. debugger manager mode to debug such exceptions.

You can start it as MANAGER in the following way:
DebuggerWithChangesHandler setupAsDebuggerOnPort: <managerPort>.

You can start it as MONITOR in the following way:
DebuggerWithChangesHandler setupAsDebuggerMonitorOnURL: 'managerHttpServerURL'  port: managerHttpServerPort listeningChangesUrl: 'myHttpServerUrl' port: myChangesServerPort.

You can start listening on all exceptions (on MONITOR side) with:
IDRAMonitor getInstance debugAll: true.