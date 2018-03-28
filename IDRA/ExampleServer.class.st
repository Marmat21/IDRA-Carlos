Class {
	#name : #ExampleServer,
	#superclass : #Object,
	#instVars : [
		'connectionSocket'
	],
	#category : #'IDRA-Debugger'
}

{ #category : #'as yet unclassified' }
ExampleServer >> interact [
	| receivedData interactionSocket interactionStream position materialization |
"Prepare socket for handling client connection requests"
connectionSocket := Socket newTCP.
connectionSocket listenOn: 12345 backlogSize: 10.
"Build a new socket for interaction with a client which connection request is accepted"
interactionSocket := connectionSocket waitForAcceptFor: 60 ifTimedOut: [ 
		connectionSocket closeAndDestroy.
		self interact ]. 
"Get rid of the connection socket since it is useless for the rest of this example"
connectionSocket closeAndDestroy.

1000 milliSeconds wait.
"OnlineDebugger getInstance connectChangesSocketOnPort: 33333."
[ interactionSocket isConnected ] whileTrue: [ 
interactionSocket waitForData.
receivedData := OrderedCollection  new.
position := 1.
[ interactionSocket dataAvailable ] whileTrue: [ 
	(interactionSocket receiveData asByteArray) appendTo: receivedData  ].
materialization := FLMaterializer materializeFromByteArray: (receivedData asByteArray ).
]

]

{ #category : #'as yet unclassified' }
ExampleServer >> serve [
[ [ self isRunning ]
whileTrue: [ self interactOnConnection ] ]
ensure: [ connectionSocket closeAndDestroy ]
]
