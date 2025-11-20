Class {
	#name : 'SSWDBPreSwappingDumbTransaction',
	#superclass : 'SSWDBDumbTransaction',
	#category : 'SSW ReStore Main',
	#package : 'SSW ReStore Main'
}

{ #category : 'actions' }
SSWDBPreSwappingDumbTransaction >> postInstallIn: aReStore [

	super postInstallIn: aReStore.
	aReStore swapAll
]
