Class {
	#name : #SSWDBStaticIdentitySetSpec,
	#superclass : #SSWDBStaticCollectionSpec,
	#category : #'SSW ReStore Collections'
}

{ #category : #'change detection' }
SSWDBStaticIdentitySetSpec >> shouldCompareChangesByEquality [

	"I represent an IdentitySet"

	^false
]
