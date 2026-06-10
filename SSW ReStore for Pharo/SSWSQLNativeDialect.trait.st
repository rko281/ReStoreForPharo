Trait {
	#name : 'SSWSQLNativeDialect',
	#category : 'SSW ReStore for Pharo',
	#package : 'SSW ReStore for Pharo'
}

{ #category : 'constants' }
SSWSQLNativeDialect classSide >> dbmsName [

	"Differentiate from superclass"

	^super dbmsName, '-Native'
]

{ #category : 'accessing' }
SSWSQLNativeDialect >> maxDateTimeResolution [

	^6
]
