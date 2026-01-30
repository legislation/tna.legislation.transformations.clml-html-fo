<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright

You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0

http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xmlns:html="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:tso="http://www.tso.co.uk/assets/namespaces/functions"
	xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:db="http://docbook.org/ns/docbook"
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:atom="http://www.w3.org/2005/Atom"
	xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:xforms="http://www.w3.org/2002/xforms" xmlns:ev="http://www.w3.org/2001/xml-events"
	xmlns:uk="https://legislation.gov.uk/akn"
	xmlns:akn="http://docs.oasis-open.org/legaldocml/ns/akn/3.0">

	<xsl:import href="impacts_xhtml.xsl"/>

	<xsl:variable name="stages" as="xs:string*" select="
			('consultation', 'development', 'enactment', 'final',
			'implementation', 'options', 'post-implementation')"/>

	<xsl:variable name="associated-doc-types" as="xs:string*" select="
			('code-of-conduct', 'code-of-practice', 'draft-policy-note',
			'equality-impact-assessment', 'explanatory-document',
			'impact-assessment', 'ni-draft-explanatory-memorandum',
			'ni-explanatory-memorandum', 'other-document',
			'policy-equality-statement', 'policy-note',
			'revised-policy-note', 'revised-uk-explanatory-memorandum',
			'revised-welsh-explanatory-memorandum', 'transposition-note',
			'uk-draft-explanatory-memorandum', 'uk-explanatory-memorandum',
			'uk-rpc-opinion', 'welsh-explanatory-memorandum')"/>

	<xsl:variable name="pattern" select="string-join(($stages, $associated-doc-types), '|')"/>

	<xsl:variable name="aknDoc" as="document-node()?" select="
			if (doc-available('input:aknData')) then
				doc('input:aknData')
			else
				()"/>

	<xsl:variable name="collection" as="document-node()?" select="
			if (doc-available('input:collection')) then
				doc('input:collection')
			else
				()"/>

	<xsl:variable name="iaStage" as="xs:string?" select="$aknDoc//akn:meta/uk:documentStage"/>

	<xsl:param name="css-path" select="'/styles/HTML5_styles/'"/>

	<xsl:template match="/">
		<xsl:choose>
			<xsl:when
				test="($paramsDoc/parameters/view = 'contents') and ($paramsDoc/parameters/format = 'html')">
				<xsl:apply-templates select="$aknDoc" mode="plain-html"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-imports/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="akn:akomaNtoso" mode="plain-html">
		<html>
			<head>
				<meta charset="utf-8"/>
				<title>
					<xsl:value-of select="$iaTitle"/>
				</title>
				<!--<link rel="stylesheet" href="{$css-path}secondary.css" type="text/css"/>-->
				<style>
					body {
					    margin: 1cm 1in;
					    font-family: arial, helvetica, verdana, sans-serif;
					    font-size: 16pt;
					}
					div.title {
					margin-bottom: 1em;
					font-size: 20pt;
					}
					/* tables of contents */
					.tocItem {
					    margin-top: 0.25em;
					}
					.tocItem[data-level = "2"] {
					    margin-left: 1em;
					}
					.tocItem[data-level = "3"] {
					    margin-left: 2em;
					}
					.tocItem[data-level = "4"] {
					    margin-left: 3em;
					}
					.tocItem[data-level = "5"] {
					    margin-left: 4em;
					}
					.tocItem[data-level = "6"] {
					    margin-left: 5em;
					}
					.tocNum + .tocHeading {
					    padding-left: 1em;
					}
					.crossheading[data-ukl-name = P1group] > h2 {
					    font-weight: bold;
					}
					a {
					    color: #0A64D7;
					    text-decoration: none;
					}
					a:hover {
					    text-decoration: underline;
					}</style>
			</head>
			<body>
				<article>
					<div class="coverPage">
						<div class="block title">
							<span class="docTitle">
								<xsl:value-of select="$iaTitle"/>
							</span>
						</div>
						<div class="toc">
							<xsl:apply-templates select="//akn:toc" mode="plain-html"/>
						</div>
					</div>
				</article>
			</body>
		</html>
	</xsl:template>

	<xsl:template match="akn:tocItem" mode="plain-html">
		<xsl:variable name="url" select="replace(substring-after(@href, 'http://www.legislation.gov.uk'), $pattern, '')"/>
		<xsl:variable name="link">
			<xsl:value-of select="concat(replace($url, '//+', '/'), '/data.html')"/>
		</xsl:variable>
		<xsl:variable name="level" select="@level"/>
		<xsl:variable name="label">
			<xsl:value-of select="tso:extract-label($url)"/>
		</xsl:variable>
		<xsl:variable name="title" select="akn:inline[@name = 'tocHeading']"/>

		<div class="tocItem" data-level="{$level}" href="{$link}" data-ukl-name="ContentsItem">
			<a href="{$link}">
				<span class="inline tocNum">
					<xsl:value-of select="$label"/>
				</span>
				<span class="inline tocHeading">
					<xsl:value-of select="$title"/>
				</span>
			</a>
		</div>
	</xsl:template>

</xsl:stylesheet>
