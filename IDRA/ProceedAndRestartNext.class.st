Class {
	#name : #ProceedAndRestartNext,
	#superclass : #DebugAction,
	#category : #'IDRA-Debugger-Actions'
}

{ #category : #registration }
ProceedAndRestartNext class >> actionType [
	<debuggingAction>
	<contextMenuDebuggingAction>
]

{ #category : #registration }
ProceedAndRestartNext class >> gtGlobalDebuggingActionFor: aDebugger [
	<gtDebuggingAction>
	
	^ (self forDebugger: aDebugger)
		label: nil
]

{ #category : #registration }
ProceedAndRestartNext class >> gtStackDebuggingActionFor: aDebugger [
	<gtStackDebuggingAction>
	
	^ (self forDebugger: aDebugger)
			icon: GLMUIThemeExtraIcons glamorousRestart
]

{ #category : #accessing }
ProceedAndRestartNext >> defaultKeymap [

	^ PharoShortcuts current restartExecutionShortcut
]

{ #category : #accessing }
ProceedAndRestartNext >> defaultLabel [

	^ 'Restart Next'
]

{ #category : #accessing }
ProceedAndRestartNext >> defaultOrder [

	^ 0
]

{ #category : #accessing }
ProceedAndRestartNext >> enabled [
	^true.
]

{ #category : #actions }
ProceedAndRestartNext >> executeAction [
	"set the restarting context to the debugger"
	IDRAManager getInstance  restartNextWithContext: self currentContext. 
	"restart to the current action"
	self session restart: self currentContext.
	"proceed this session"
	self session resume.
	
	
	
]

{ #category : #accessing }
ProceedAndRestartNext >> id [

	^ #restartNext
]
