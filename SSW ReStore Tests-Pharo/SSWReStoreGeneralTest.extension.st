Extension { #name : #SSWReStoreGeneralTest }

{ #category : #'*SSW ReStore Tests-Pharo' }
SSWReStoreGeneralTest >> defaultTimeLimit [

	^20 seconds
]

{ #category : #'*SSW ReStore Tests-Pharo' }
SSWReStoreGeneralTest >> expectedFailures [

	"ListModel and therefore events are not supported in Pharo"
	^super expectedFailures, #(#test01Events)
]
