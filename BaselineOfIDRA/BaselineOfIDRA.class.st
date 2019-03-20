Class {
	#name : #BaselineOfIDRA,
	#superclass : #BaselineOf,
	#category : #BaselineOfIDRA
}

{ #category : #baselines }
BaselineOfIDRA >> baseline: spec [ 
	<baseline>
	spec
		for: #common
		do: [ spec
			baseline: 'TaskIt' 
				with: [ spec repository: 'github://sbragagnolo/taskit' ] ;
				package: #IDRA.
			spec
				group: 'minimal' with: #('IDRA');
				group: 'default'
					with: #('minimal'  ) ].

]
