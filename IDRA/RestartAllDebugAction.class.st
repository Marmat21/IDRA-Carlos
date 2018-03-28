Class {
	#name : #RestartAllDebugAction,
	#superclass : #DebugAction,
	#category : #'IDRA-Debugger-Actions'
}

{ #category : #registration }
RestartAllDebugAction class >> actionType [
	<debuggingAction>
	<contextMenuDebuggingAction>
]

{ #category : #registration }
RestartAllDebugAction class >> gtGlobalDebuggingActionFor: aDebugger [
	<gtDebuggingAction>
	
	^ (self forDebugger: aDebugger)
		label: nil
]

{ #category : #registration }
RestartAllDebugAction class >> gtStackDebuggingActionFor: aDebugger [
	<gtStackDebuggingAction>
	
	^ (self forDebugger: aDebugger)
			icon: GLMUIThemeExtraIcons glamorousRestart
]

{ #category : #accessing }
RestartAllDebugAction >> defaultKeymap [

	^ PharoShortcuts current restartExecutionShortcut
]

{ #category : #accessing }
RestartAllDebugAction >> defaultLabel [

	^ 'Restart All'
]

{ #category : #accessing }
RestartAllDebugAction >> defaultOrder [

	^ 0
]

{ #category : #accessing }
RestartAllDebugAction >> enabled [
	^true.
]

{ #category : #actions }
RestartAllDebugAction >> executeAction [
	"set the restarting context to the debugger"
	| act |
	IDRAManager getInstance  setRestartingContext: self currentContext. 
	"restart to the current action"
	self session restart: self currentContext.
	"self debugger close."
	"proceed this session"
	"self session resume."
	act := ResumeDebugAction forDebugger: self debugger.
	act executeAction.

	
	
	
	
]

{ #category : #accessing }
RestartAllDebugAction >> id [

	^ #restartAll
]
