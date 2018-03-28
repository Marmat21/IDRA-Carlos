Trait {
	#name : #TSerializingProtocol,
	#category : #'IDRA-Debugger'
}

{ #category : #'as yet unclassified' }
TSerializingProtocol >> interactWithSocket: interactionSocket [
	self interactWithSocket: interactionSocket  executing: [ ]  
]

{ #category : #'as yet unclassified' }
TSerializingProtocol >> interactWithSocket: interactionSocket executing: aBlock [
	| receivedData materialization failCount sync size |
	1 inform: 'connection with client is correctly setup'.
	[ [ interactionSocket isConnected ]
		whileTrue: [ interactionSocket waitForData.
			failCount := 0.
			receivedData := OrderedCollection new.
			interactionSocket dataAvailable
				ifTrue: [ sync := (interactionSocket receiveData: 8) asByteArray.
					sync = (self syncWord)
						ifTrue: [ size := (interactionSocket receiveData: 4) asByteArray asInteger ]
						ifFalse: [ 1 inform: 'problem'.
							sync appendTo: receivedData ].
					[ receivedData size = size ]
						whileFalse: [ (interactionSocket receiveData: size - receivedData size) asByteArray
								appendTo: receivedData ] ].
						
			[ materialization := FLMaterializer materializeFromByteArray: receivedData asByteArray.
			"execute the block"
			aBlock cull: materialization. ]
				on: Error
				do: [ :e | 
					1 inform: 'there was a materialization error'.
					1 inform: e description ] ] ]
		on: ConnectionClosed
		do: [ 1 inform: 'Client disconnected' ]
]

{ #category : #'as yet unclassified' }
TSerializingProtocol >> serializeAnObject: anObject OnSocket: aSocket withSerializer: aSerializer [
	| sentStream |
	sentStream := ByteArray streamContents: [ :s | aSerializer serialize: anObject on: s ].
	aSocket nextPutAll:  self syncWord .
	aSocket nextPutAll: (sentStream size asByteArrayOfSize: 4).
	aSocket nextPutAll: sentStream.
	aSocket flush.
]

{ #category : #'as yet unclassified' }
TSerializingProtocol >> syncWord [
	^ #(0 0 0 0 1 1 1 1) asByteArray 
]
