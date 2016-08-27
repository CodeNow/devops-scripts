#!/usr/bin/env node

'use strict';

var aws = require('aws-sdk');
var ec2 = new aws.EC2({
    accessKeyId: 'AKIAJ3RCYU6FCULAJP2Q',
    secretAccessKey: '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',
    region: 'us-west-2'
});

var name = process.argv[1];

// console.log(name,"xxx");

var params = {
    Filters: [
        // Only search for docks in the cluster security group
    {
        Name: 'vpc-id',
        Values: ['vpc-cdb2a3a8']
    },
    // Only fetch running instances
    {
        Name: 'instance-state-name',
        Values: ['running']
    }
    ]
};

ec2.describeInstances(params, function (err, data) {
    if (err) {
        console.error("An error occurred: ", err);
        process.exit(1);
    }

    // Get a set of instances from the describe response
    var instances = [];
    data.Reservations.forEach(function (res) {
        res.Instances.forEach(function (instance) {
            instances.push(instance);
        });
    });

    // Map the instances to their private ip addresses
    // NOTE This will work locally because of the wilcard ssh proxy in the config
    var hosts = instances.map(function (instance) {
        return instance.PrivateIpAddress;
    });

    var hostVars = {};
    var out = {}
    instances.forEach(function (instance) {
        for (var i = 0; i < instance.Tags.length; i++) {
            if (instance.Tags[i].Key === 'role' ) {
                if ( !out[instance.Tags[i].Value]) {
                    out[instance.Tags[i].Value]={hosts: []}
                }
                out[instance.Tags[i].Value].hosts.push( instance.PrivateIpAddress)
            }
        }
    });

    // Output the resulting JSON
    // NOTE http://docs.ansible.com/ansible/developing_inventory.html
    console.log(JSON.stringify(out));
});
