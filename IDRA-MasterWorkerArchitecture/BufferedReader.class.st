Class {
	#name : #BufferedReader,
	#superclass : #Object,
	#instVars : [
		'buffers'
	],
	#category : #'IDRA-MasterWorkerArchitecture'
}

{ #category : #'as yet unclassified' }
BufferedReader >> bufferFileStreamFrom: inputStream [
	| buffer totalRead |
	buffer := (inputStream isBinary ifTrue: [ ByteArray ] ifFalse: [ String ]) new: ZnUtils streamingBufferSize.
	totalRead := 0.
	[ inputStream atEnd ]
		whileFalse: [ | readCount |
			readCount := inputStream readInto: buffer startingAt: 1 count: buffer size.
			readCount > 0
				ifTrue: [
					totalRead := totalRead + readCount.
					buffers add: (buffer copy).].
			inputStream atEnd
				ifFalse: [
					ZnUtils signalProgress: totalRead total: nil. 
					"outputStream flush" ] ]
]

{ #category : #'as yet unclassified' }
BufferedReader >> bufferStreamFrom: inputStream [
	| buffer totalRead |
	buffer := (inputStream isBinary ifTrue: [ ByteArray ] ifFalse: [ String ]) new: ZnUtils streamingBufferSize.
	totalRead := 0.
	[ inputStream atEnd ]
		whileFalse: [ | readCount |
			readCount := inputStream readInto: buffer startingAt: 1 count: buffer size.
			readCount > 0
				ifTrue: [
					totalRead := totalRead + readCount.
					buffers add: (buffer copy).].
			inputStream atEnd
				ifFalse: [
					ZnUtils signalProgress: totalRead total: nil. 
					"outputStream flush" ] ]
]

{ #category : #accessing }
BufferedReader >> buffers [
	^buffers.
]

{ #category : #testing }
BufferedReader >> hasNext [
	^(buffers size > 0)
]

{ #category : #initialization }
BufferedReader >> initialize [
	buffers := OrderedCollection new.
]

{ #category : #'as yet unclassified' }
BufferedReader >> takeFirst [ 
	^buffers removeFirst.
]
