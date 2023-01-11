Class {
	#name : #SSWDBStaticIdentitySetSpec,
	#superclass : #SSWDBHashedStaticCollectionSpec,
	#category : #'SSW ReStore Collections'
}

{ #category : #'change detection' }
SSWDBStaticIdentitySetSpec >> shouldCompareChangesByEquality [

	"I represent an IdentitySet"

	^false
]
