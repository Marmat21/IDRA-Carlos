Class {
	#name : #TupleHostsDataSource,
	#superclass : #FTSimpleDataSource,
	#category : #'IDRA-Debugger'
}

{ #category : #accessing }
TupleHostsDataSource >> cellColumn: column row: rowIndex [

	(column id = 'Local Port') ifTrue: [ 
	^ FTCellMorph new
		addMorphBack: ((self elementAt: rowIndex) first) asMorph;
		yourself].
	^ FTCellMorph new
		addMorphBack: ((self elementAt: rowIndex) second) asMorph;
		yourself.
]
