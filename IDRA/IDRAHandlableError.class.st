Class {
	#name : #IDRAHandlableError,
	#superclass : #OnlineHandlableError,
	#category : #'IDRA-Exceptions'
}

{ #category : #exceptiondescription }
IDRAHandlableError >> defaultAction [
	|copy |
	((IDRAMonitor getInstance isNotNil) and: [(IDRAMonitor getInstance started)]) ifTrue: [ 
	copy := self copyContext .
	[ (IDRAMonitor getInstance) handleError: self inContext: copy ] fork. ]
	ifFalse: [ 
		^super defaultAction ]
]
