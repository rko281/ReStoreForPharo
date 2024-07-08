Extension { #name : 'Process' }

{ #category : '*SSW ReStore Main' }
Process >> reStore [

	"Return the affiliated ReStore instance for this process.
	If no explicit affiliation the global default is used"

	^(SSWReStore affiliateFor: self) ifNil: [SSWReStore globalDefault]
]

{ #category : '*SSW ReStore Main' }
Process >> reStore: aReStoreOrNil [

	"Set aReStore(OrNil) as the affiliated instance in this process.
	If nil any current affiliation is removed and the global default is assumed"

	aReStoreOrNil isNil 
		ifTrue: [(SSWReStore affiliateFor: self) ifNotNil: [ :reStore | reStore disaffiliateWith: self]]
		ifFalse: [aReStoreOrNil affiliateWith: self using: [ :proc | Processor activeProcess == proc]]
]
