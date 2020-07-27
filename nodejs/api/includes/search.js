"use strict";
exports = module.exports = function ( server ) {

    const Nightmare = require( 'nightmare' );
    const beautify = require( "json-beautify" );
    const fs = require( "fs" );
    const elasticlunr = require( "elasticlunr" );
    const removeAccents = require( "remove-accents" );
    const htmlToText = require( 'html-to-text' );
    require( 'lunr-languages/lunr.stemmer.support.js' )( elasticlunr );
    require( 'lunr-languages/lunr.fr.js' )( elasticlunr );

    const config = {
        menu: "#accordion > div",
        left: "#mainWiki > div.row > div.col-xs-12.col-sm-9",
        tabs: "ul.nav > li > a",
        tabpanel: "div.tab-pane:not(.ng-hide)",
        output: "/home/nodejs/api/includes/data/search.json",
        speed: 100,
        linkList: [],
        blacklist: [
            "comment", "aide", "quoi", "trouver", "rapidement",
            "il", "elle", "on", "ils", "elles",
            "mon", "ton", "son",
            "ma", "ta", "sa", "ca",
            "me", "te", "se", "ce",
            "le", "la", "les", "lui",
            "un", "une", "de", "du",
            "sont", "est", "ces", "ses", "sait", "sais", "c'est", "s'est",
            "avoir", "a", "ait", "ai", "et"
        ]
    }

    const DB = JSON.parse(fs.readFileSync( config.output ));

    const indexDB = elasticlunr( function () {
        this.addField( 'title' );
        this.addField( 'body' );
        this.addField( 'url' );
        this.setRef( 'id' );
        this.use( elasticlunr.fr );
    } );


    elasticlunr.addStopWords( config.blacklist );
    for ( let i in DB ) {
        indexDB.addDoc( DB[i] );
    }

    server.get( '/search/aide/:str', function ( req, res, next ) {
        let search = indexDB.search( clearSTR( req.params['str'] ), { fields: { url: { boost: 2 }, title: { boost: 3 }, body: { boost: 1 } }, expand: true } ).slice( 0, 3 );
        let ret = [];

        for ( let j = 0; j < search.length; j++ ) {
            const elem = search[j];
            ret.push( {
                url: DB[elem.ref].url,
                title: DB[elem.ref].title,
                score: elem.score
            } );
        }

        return res.send( ret );
        next();
    } );



    String.prototype.replaceAll = function ( search, replacement ) {
        return this.split( search ).join( replacement );
    };
    function clearSTR( str, html ) {
        if ( html ) {
            str = htmlToText.fromString( str, {
                format: {
                    image: function ( node, fn, options ) {
                        return "===" + ( node.attribs.alt ? node.attribs.alt : "" ) + "===";
                    },
                    text: function ( node, fn, options ) {
                        return "===" + clearSTR( node.data ) + "===";
                    },
                },
                wordwrap: null,
                ignoreHref: true,
                uppercaseHeadings: false,
                singleNewLineParagraphs: true
            } );
        }
        str = str.replaceAll( "'", " " ).replaceAll( "\"", " " ).replaceAll( "-", "" ).replaceAll( "[", " " ).replaceAll( "]", " " ).replaceAll( "===", " " )
        str = str.replaceAll( "\n", " " ).replaceAll( "\t", " " );
        str = str.replace( /\s{2,}/g, " " );
        str = str.replace( "https://www.ts-x.eu/index.php?page=aide&sub=", "" );
        return removeAccents( str ).trim();
    }

};
