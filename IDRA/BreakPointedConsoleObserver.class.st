Class {
	#name : #BreakPointedConsoleObserver,
	#superclass : #Observer,
	#instVars : [
		'limit'
	],
	#category : #'IDRA-Generator'
}

{ #category : #'as yet unclassified' }
BreakPointedConsoleObserver >> notifyWith: aValue [
	aValue < 999 ifTrue:[
		Transcript crShow: aValue
	] ifFalse: [ 
		self simulatedHalt.
		Transcript crShow: 'overBreakpoint'
		
	 ]
]
