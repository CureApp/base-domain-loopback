# base-domain-loopback

## creates custom model-definitions for loopback-with-admin

    modelDefinitions = require('base-domain-loopback').getModelDefinitions(domain)

    require('loopback-with-admin').run(modelDefinitions)

## creates facade classes with loopback access
    require('base-domain-loopback').createInstance(baseURL: 'localhost:3000/api')

## creates repository classes with loopback access

    class MaterialRepository require('base-domain-loopback').LoopbackRepository
    class PatientRepository require('base-domain-loopback').LoopbackUserRepository
    class TalkRepository require('base-domain-loopback').LoopbackRelationRepository
