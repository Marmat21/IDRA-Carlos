Class {
	#name : #BaselineOfIDRA,
	#superclass : #Object,
	#category : #BaselineOfIDRA
}

{ #category : #baselines }
BaselineOfIDRA >> baseline: spec [ 
	spec
		for: #common
		do: [ spec
			baseline: 'TaskIt' 
				with: [ spec repository: 'github://sbragagnolo/taskit' ] ;
				package: #IDRA;
				package: #'IDRA-MasterWorkerArchitecture' with: [ spec requires: #('TaskIt' 'IDRA') ];
				package: #'IDRA-TestRunner' with: [ spec requires: #('IDRA-MasterWorkerArchitecture') ];
				package: #'TwitterApplication' with: [ spec requires: #('IDRA-MasterWorkerArchitecture') ].
			spec
				group: 'minimal' with: #('IDRA');
				group: 'default'
					with: #('minimal' 'IDRA-MasterWorkerArchitecture' 'IDRA-TestRunner' 'TwitterApplication' ) ].

]
