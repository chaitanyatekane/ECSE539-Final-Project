/*
 * generated by Xtext 2.23.0
 */
package ca.mcgill.sel.perspectivedsl.ca.mcgill.sel;


/**
 * Initialization support for running Xtext languages without Equinox extension registry.
 */
public class PerspectiveDSLStandaloneSetup extends PerspectiveDSLStandaloneSetupGenerated {

	public static void doSetup() {
		new PerspectiveDSLStandaloneSetup().createInjectorAndDoEMFRegistration();
	}
}
