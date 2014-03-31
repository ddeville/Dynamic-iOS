//
//  LLViewController.m
//  Dynamic
//
//  Created by Damien DeVille on 3/31/14.
//  Copyright (c) 2014 Damien DeVille. All rights reserved.
//

#import "LLViewController.h"

#import <MobileCoreServices/MobileCoreServices.h>

#import "Library.h"

#import "Framework/Framework.h"

@interface NSObject (PluginInterface)

- (void)sayHello;

@end

#pragma mark -

@interface LLViewController ()

@property (strong, nonatomic) NSSet *pluginIdentifiers;

@end

@implementation LLViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[self setTitle:NSLocalizedString(@"Greetings", @"LLViewController title")];
}

#pragma mark - Actions

- (IBAction)sayHelloDynamic:(id)sender
{
	Library *library = [[Library alloc] init];
	[library sayHello];
}

- (IBAction)sayHelloFramework:(id)sender
{
	Framework *framework = [[Framework alloc] init];
	[framework sayHello];
}

static NSString * const LLPluginTypeIdentifier = @"com.ddeville.llplugin";

- (IBAction)loadPlugins:(id)sender
{
	NSURL *documentsLocation = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]];
	
	NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:documentsLocation includingPropertiesForKeys:@[NSFileType] options:(NSDirectoryEnumerationOptions)0 error:NULL];
	
	__block BOOL foundPlugin = NO;
	
	[contents enumerateObjectsUsingBlock:^ (NSURL *fileURL, NSUInteger idx, BOOL *stop) {
		NSString *fileType = [fileURL resourceValuesForKeys:@[NSURLTypeIdentifierKey] error:NULL][NSURLTypeIdentifierKey];
		if (fileType == nil) {
			return;
		}
		if (!UTTypeConformsTo((__bridge CFStringRef)fileType, (__bridge CFStringRef)LLPluginTypeIdentifier)) {
			return;
		}
		
		[self _loadPluginAtLocation:fileURL];
		foundPlugin = YES;
	}];
	
	if (!foundPlugin) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn\u2019t Find Plugin" message:@"No plugin could be found. Make sure that you manually copy a plugin into the Documents directory." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
	}
}

- (IBAction)sayHelloPlugin:(id)sender
{
	NSString *pluginIdentifier = [[self pluginIdentifiers] anyObject];
	if (pluginIdentifier == nil) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Plugin Loaded" message:@"Please load the plugins first." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		return;
	}
	
	NSBundle *plugin = [NSBundle bundleWithIdentifier:pluginIdentifier];
	
	id pluginInstance = [[[plugin principalClass] alloc] init];
	if (![pluginInstance respondsToSelector:@selector(sayHello)]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unexpected Plugin" message:@"The plugin doesn\u2019t have the expected type." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		return;
	}
	
	[pluginInstance sayHello];
}

#pragma mark - Private

- (void)_loadPluginAtLocation:(NSURL *)pluginLocation
{
	NSBundle *plugin = [[NSBundle alloc] initWithURL:pluginLocation];
	
	BOOL loaded = [plugin load];
	if (!loaded) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Load Plugin" message:@"The plugin couldn\u2019t be loaded." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		return;
	}
	
	NSError *preflightError = nil;
	BOOL preflight = [plugin preflightAndReturnError:&preflightError];
	if (!preflight) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Load Plugin" message:[NSString stringWithFormat:@"The plugin couldn\u2019t be preflighted: %@", [preflightError localizedDescription]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		return;
	}
	
	Class pluginClass = [plugin principalClass];
	if (pluginClass == nil) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Load plugin" message:@"The plugin principal class couldn\u2019t be retrieved." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		return;
	}
	
	NSString *pluginIdentifier = [plugin bundleIdentifier];
	if (pluginIdentifier == nil) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Load plugin" message:@"The plugin bundle identifier couldn\u2019t be retrieved." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		return;
	}
	
	NSMutableSet *pluginIdentifiers = [NSMutableSet setWithSet:[self pluginIdentifiers]];
	[pluginIdentifiers addObject:pluginIdentifier];
	[self setPluginIdentifiers:pluginIdentifiers];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Plugin Loaded!" message:[NSString stringWithFormat:@"The plugin with bundle identifier %@ was loaded.", pluginIdentifier] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}

@end
