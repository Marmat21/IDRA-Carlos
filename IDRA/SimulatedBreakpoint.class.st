Class {
	#name : #SimulatedBreakpoint,
	#superclass : #Object,
	#category : #'IDRA-Exceptions'
}

{ #category : #break }
SimulatedBreakpoint class >> break [
	OnlineHandlableBreakpoint new signal.
]

{ #category : #break }
SimulatedBreakpoint >> break [
	OnlineHandlableBreakpoint signal.
]
