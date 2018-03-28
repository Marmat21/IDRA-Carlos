Class {
	#name : #TupleDataSource,
	#superclass : #FTSimpleDataSource,
	#category : #'IDRA-Debugger'
}

{ #category : #accessing }
TupleDataSource >> cellColumn: column row: rowIndex [

	(column id = 'Error Name') ifTrue: [ 
	^ FTCellMorph new
		addMorphBack: ((self elementAt: rowIndex) first) asMorph;
		yourself].
	^ FTCellMorph new
		addMorphBack: ((self elementAt: rowIndex) second) asMorph;
		yourself.
]
