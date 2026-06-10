Class {
	#name : 'SSWPostgreSQLNativeDialect',
	#superclass : 'SSWPostgreSQLDialect',
	#traits : 'SSWSQLNativeDialect',
	#classTraits : 'SSWSQLNativeDialect classTrait',
	#category : 'SSW ReStore P3',
	#package : 'SSW ReStore P3'
}

{ #category : 'constants' }
SSWPostgreSQLNativeDialect >> defaultDateTimeResolution [

	^self maxDateTimeResolution
]
