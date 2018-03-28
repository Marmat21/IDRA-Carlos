Class {
	#name : #UseCaseTestCase,
	#superclass : #TestCase,
	#category : #'IDRA-Test'
}

{ #category : #tests }
UseCaseTestCase >> testAssertionError [
	|a|
	
a := 5.
self assert: (a < 6) equals: true.
]

{ #category : #tests }
UseCaseTestCase >> testAssertionErrorAgain [
	|a|
	
a := 7.
self assert: (a < 6) equals: true.
]
