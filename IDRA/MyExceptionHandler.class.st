Class {
	#name : #MyExceptionHandler,
	#superclass : #TKTDebuggerExceptionHandler,
	#category : #'IDRA-Exceptions'
}

{ #category : #handling }
MyExceptionHandler >> copyContextOfException: anException [
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
MyExceptionHandler >> handleException: arg1 [
	| tmp1 |
	1 inform: 'gotAnException'.
	tmp1 := self copyContextOfException: arg1.
	(self isBreakpoint: arg1)
		ifTrue: [ tmp1 := tmp1 sender sender.
			[ IDRAMonitor  getInstance
				handleBreakpoint: arg1
				inContext: tmp1
				strategy: DefaultStrategy ] fork ]
		ifFalse: [ [ IDRAMonitor  getInstance
				handleError: arg1
				inContext: tmp1
				strategy: DefaultStrategy ] fork ]
]

{ #category : #handling }
MyExceptionHandler >> isBreakpoint: anException [
	^(anException class = OnlineHandlableBreakpoint ).
]
