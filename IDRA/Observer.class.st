Class {
	#name : #Observer,
	#superclass : #Object,
	#instVars : [
		'debugger'
	],
	#category : #'IDRA-Generator'
}

{ #category : #'as yet unclassified' }
Observer >> debugger: aDebugger [
	debugger := aDebugger
]

{ #category : #'as yet unclassified' }
Observer >> initialize [
	debugger := IDRADebugger getInstance.
]

{ #category : #'as yet unclassified' }
Observer >> notifyWith: aValue [
	"method where the observer is notified of a new value"
	[ self basicNotifyWith: aValue ] on: Error forkAndCopyContext: [ 
	:exception :forkedContext | debugger handleError: exception inContext: forkedContext  ]
]
