Class {
	#name : #PiExceptionHandler,
	#superclass : #TKTDebuggerExceptionHandler,
	#category : #'IDRA-Exceptions'
}

{ #category : #handling }
PiExceptionHandler >> copyContextOfException: anException [
		| copy currentLevel sender senderCopy |
		copy := anException signalerContext  copy.
		currentLevel := copy.
		sender := currentLevel sender.
		[sender == nil ] whileFalse: [ 
			senderCopy := sender copy.
			currentLevel privSender: senderCopy.
			sender := sender sender.
			currentLevel := senderCopy.
			].
		^copy.
]

{ #category : #handling }
PiExceptionHandler >> handleException: exception [
	| copy |
	1 inform: 'gotAnException'.
	copy := self copyContextOfException: exception.
	copy := copy sender sender.
	[ IDRADebugger getInstance
		handleBreakpoint: exception
		inContext: copy
		strategy: NoRestartStrategy ] fork
]
