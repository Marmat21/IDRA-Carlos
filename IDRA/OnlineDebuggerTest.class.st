Class {
	#name : #OnlineDebuggerTest,
	#superclass : #Object,
	#instVars : [
		'generator'
	],
	#category : #'IDRA-Test'
}

{ #category : #tests }
OnlineDebuggerTest >> cleanClientRun [
"returns the generator. Be careful to stop it!"
	| obs|
	IDRADebugger resetInstance.
	IDRADebugger setMonitorModeWithServerIP: 'localhost' port: 12345.
]

{ #category : #tests }
OnlineDebuggerTest >> clientRun [
"returns the generator. Be careful to stop it!"
	| obs|
	IDRADebugger resetInstance.
	IDRADebugger setMonitorModeWithServerIP: 'localhost' port: 12345.
	obs := DirectlyBuggedConsoleObserver new.
	generator := DataGenerator new.
	generator registerNewObserver: obs.
	generator start.
]

{ #category : #tests }
OnlineDebuggerTest >> generator [
	^generator.
]

{ #category : #tests }
OnlineDebuggerTest >> serverRun [
	IDRADebugger resetInstance.
	IDRADebugger setClientMode: false.
	[ ExampleServer new interact ] fork.
]

{ #category : #tests }
OnlineDebuggerTest >> simpleRun [
| obs gen|
IDRADebugger resetInstance.
gen := DataGenerator new.
obs := BuggedConsoleObserver new.
gen registerNewObserver: obs.
gen start.
]

{ #category : #tests }
OnlineDebuggerTest >> testDebuggerOpening [
| obs prod |
	obs := BuggedConsoleObserver  new.
	prod := DataGenerator new.
	prod registerNewObserver: obs.
	prod start.
	[1 seconds wait.
	prod stop.] fork
]

{ #category : #tests }
OnlineDebuggerTest >> testSimpleGeneration [
| obs prod |
	obs := ConsoleObserver new.
	prod := DataGenerator new.
	prod registerNewObserver: obs.
	prod start.
	[20 seconds wait.
	prod stop.] fork
]
