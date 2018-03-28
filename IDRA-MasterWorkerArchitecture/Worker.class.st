Class {
	#name : #Worker,
	#superclass : #Object,
	#instVars : [
		'runner',
		'interactionSocket'
	],
	#category : #'IDRA-MasterWorkerArchitecture'
}

{ #category : #initialization }
Worker >> initialize [
	runner := TKTNewProcessTaskRunner new.
	runner exceptionHandler: MyExceptionHandler new.
]

{ #category : #initialization }
Worker >> interactionSocket [
	^interactionSocket.
]

{ #category : #'as yet unclassified' }
Worker >> listenForTasksOnPort: aPort [
	| receivedData position materialization connectionSocket commandEntry |
"Prepare socket for handling client connection requests"
connectionSocket := Socket newTCP.
connectionSocket listenOn: aPort backlogSize: 10.
"Build a new socket for interaction with a client which connection request is accepted"
interactionSocket := connectionSocket waitForAcceptFor: 60. 

1 inform: 'accepted'.
"Get rid of the connection socket since it is useless for the rest of this example"
"connectionSocket closeAndDestroy."
"interactionStream := SocketStream on: interactionSocket.
interactionStream binary.
receivedData   := interactionStream  receiveData.
(FLMaterializer materializeFromByteArray: receivedData) run."

[ interactionSocket isConnected ] whileTrue: [ 
interactionSocket waitForData.
receivedData := OrderedCollection  new.
position := 1.
[ interactionSocket dataAvailable ] whileTrue: [ 
	(interactionSocket receiveData asByteArray) appendTo: receivedData.
	(interactionSocket dataAvailable) ifFalse: [ (50 milliSeconds ) wait ]  ].
materialization := FLMaterializer materializeFromByteArray: (receivedData asByteArray ).
commandEntry := materialization.
self scheduleCommand: (commandEntry first) parameters: (commandEntry second).
]
]

{ #category : #accessing }
Worker >> runner [
	^runner.
]

{ #category : #'as yet unclassified' }
Worker >> scheduleCommand: aCommand parameters: someParameters [
self subclassResponsibility.

]

{ #category : #'as yet unclassified' }
Worker >> sendToMaster: anObject [
	
	| ss |
	ss := SocketStream on: interactionSocket.
	ss binary.
FLSerializer serialize: anObject on: ss.

1 inform: 'sent anObject to Master'
]
