Class {
	#name : #IDRADebuggerProcess,
	#superclass : #Process,
	#instVars : [
		'debugSession'
	],
	#category : #'IDRA-Debugger'
}

{ #category : #accessing }
IDRADebuggerProcess >> debugSession [
	^debugSession.
]

{ #category : #accessing }
IDRADebuggerProcess >> fuelAccept: aGeneralMapper [
    aGeneralMapper visitSubstitution: self by: nil
]

{ #category : #'as yet unclassified' }
IDRADebuggerProcess >> newDebugSessionNamed: aString startedAt: aContext [
	"open here my extension of debugsession"
	^DebugSession named: aString on: self startedAt: aContext
]

{ #category : #accessing }
IDRADebuggerProcess >> proceedDebugSessionStartedAt: aContext [
	"open here my extension of debugsession"
	debugSession := DebugSession named: 'Temp Debug' on: self startedAt: aContext.
	^debugSession.
]
