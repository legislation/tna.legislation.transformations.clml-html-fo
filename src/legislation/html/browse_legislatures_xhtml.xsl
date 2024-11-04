<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<!-- UI Legislation Browse output  -->
<!-- Version 0.01 -->
<!-- Created by Faiz Muhammad -->
<!-- Last changed 07/05/2010 by Faiz Muhammad -->
<!-- Change history

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" version="2.0"
				xmlns:xhtml="http://www.w3.org/1999/xhtml"
				xmlns:xs="http://www.w3.org/2001/XMLSchema"
				xmlns:tso="http://www.tso.co.uk/assets/namespaces/functions"
				xmlns:dc="http://purl.org/dc/elements/1.1/"
				xmlns:db="http://docbook.org/ns/docbook"
				xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
				xmlns:atom="http://www.w3.org/2005/Atom"
				xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation"
				xmlns:xforms="http://www.w3.org/2002/xforms"
				xmlns:ev="http://www.w3.org/2001/xml-events">

	<xsl:import href="quicksearch.xsl"/>
	<xsl:import href="../../common/utils.xsl"/>

	<!-- ========== Standard code for outputing UI wireframes========= -->
	<xsl:variable name="paramsDoc" select="if (doc-available('input:request')) then doc('input:request') else ()"/>

	<xsl:template match="/">
		<html>
			<head>
				<title><xsl:value-of select="leg:TranslateText('Explore our collections')"/></title>
				<link type="text/css" href="/styles/legBrowseCards.css" rel="stylesheet"/>
				<xsl:comment>
					<![CDATA[[if lte IE 6]><link rel="stylesheet" href="/styles/IE/ie6browseAdditions.css" type="text/css" /><![endif]]]></xsl:comment>
				<xsl:comment>
					<![CDATA[[if IE 7]><link rel="stylesheet" href="/styles/IE/ie7browseAdditions.css" type="text/css" /><![endif]]]></xsl:comment>
			</head>
			<!-- TSOBrowseHome has a different body@class -->
			<body xml:lang="{$TranslateLang}" dir="ltr" id="browse" class="intro">
				<div id="layout2">
					<xsl:call-template name="TSOOutputQuickSearch"/>
					<div class="info-content">						
						<ul class="breadcrumb">
							<li><a href="/"><xsl:value-of select="leg:TranslateText('Home')"/></a></li>	
							<li><a href="/explore"><xsl:value-of select="leg:TranslateText('Explore our collections')"/></a></li>	
							<li><a href="#" style="font-weight:500;"><xsl:value-of select="leg:TranslateText('Different legislatures of the UK')"/></a></li>
						</ul>
						<h1><xsl:value-of select="leg:TranslateText('Different legislatures of the UK')"/></h1>
						<xsl:for-each select="('browsecards_parliaments')">
							<xsl:variable name="file" select="concat('../../../www/browse/',.,'.atom.xml')"/>
							<xsl:if test="doc-available($file)">
								<xsl:apply-templates select="doc($file)" mode="cards"/>
							</xsl:if>
						</xsl:for-each>
					</div>
				</div>
				<div class="also-interested">
					<h2>You might also be interested in finding out about...</h2>
					<ul>
						<li>
							<a href="/eu-legislation-and-uk-law">
								<h3>Legislation originating from the EU</h3>
								<p>EU legislation as it applied to the UK on 31 Dec 2020, with any changes since made by the UK applied.</p>
							</a>
						</li>
						<li>
							<a href="/understanding-legislation#parliamentsandjurisdictions">
								<h3>UK Parliaments and jurisdictions</h3>
								<p>The different legislatures of the UK, their history and how the UK Parliaments have changed over time.</p>
							</a>
						</li>
						<li>
							<a href="/help#aboutLeg">
								<h3>What legislation we hold</h3>
								<p>We hold most, but not all, types of legislation and their accompanying explanatory documents. See a complete list of what we hold.</p>
							</a>
						</li>
						<li>
							<a href="/understanding-legislation">
								<h3>How legislation works</h3>
								<p>Find out how laws get made, what various terms mean, how legislation can change other legislation and what revised legislation is.</p>
							</a>
						</li>
						<li>
							<a href="/understanding-legislation#editorialpractice">
								<h3>Our editorial process</h3>
								<p>Find out what legislation we revise, our timescales for revision, the conventions we follow and the principles that we abide by.</p>
							</a>
						</li>
					</ul>
				</div>
			</body>
		</html>
	</xsl:template>

	<xsl:template match="atom:feed" mode="cards">
			<ul class="content-cards">
				<xsl:apply-templates select="atom:entry" mode="cards"/>
			</ul>
	</xsl:template>

	<xsl:template match="atom:title" mode="cards">
		<h2>
			<xsl:apply-templates mode="cards"/>
		</h2>
	</xsl:template>
	<xsl:template match="atom:entry/atom:title" mode="cards">
		<h3>
			<xsl:apply-templates mode="cards"/>
		</h3>
	</xsl:template>

	<xsl:template match="atom:entry" mode="cards">
		<xsl:variable name="id" select="tokenize(./atom:id,'#')[2]"/>
		<li id="{$id}">
			<a>
				<xsl:attribute name="class" select="atom:img"/>
				<xsl:attribute name="href">
					<xsl:if test="not(./atom:category/@term = 'en-only')">
						<xsl:value-of select="$TranslateLangPrefix"/>
					</xsl:if>
					<xsl:value-of select="./atom:link/@href"/>
				</xsl:attribute>
				<xsl:apply-templates select="atom:title" mode="cards"/>
				<xsl:apply-templates select="atom:content" mode="cards"/>
			</a>
		</li>
	</xsl:template>
	<!--paragraph with the class of element name-->
	<xsl:template match="atom:summary|atom:content" mode="cards">
		<p>
			<xsl:apply-templates mode="cards"/>
		</p>
	</xsl:template>
	<!--Don't output these-->
	<xsl:template match="atom:link|atom:id|atom:updated|atom:category" mode="cards"/>

	<xsl:template match="text()" mode="cards" priority="1">
		<xsl:copy-of select="leg:TranslateNode(.)"/>
	</xsl:template>

	<xsl:template match="atom:entry[child::atom:link[@href='/explore/legislatures/eu']]" mode="cards"/>
</xsl:stylesheet>