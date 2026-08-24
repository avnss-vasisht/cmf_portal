using System;

namespace System.DirectoryServices.AccountManagement
{
    public enum ContextType
    {
        Domain = 0
    }

    public enum IdentityType
    {
        SamAccountName = 0
    }

    public class PrincipalContext : IDisposable
    {
        public PrincipalContext(ContextType contextType, string name)
        {
            ContextType = contextType;
            Name = name;
        }

        public ContextType ContextType { get; private set; }

        public string Name { get; private set; }

        public void Dispose()
        {
            // No-op stub for environments without AD assemblies.
        }
    }

    public class UserPrincipal
    {
        public string DisplayName { get; set; }

        public static UserPrincipal FindByIdentity(PrincipalContext context, string identityValue)
        {
            // AD lookup is unavailable in this environment.
            return null;
        }

        public static UserPrincipal FindByIdentity(PrincipalContext context, IdentityType identityType, string identityValue)
        {
            // AD lookup is unavailable in this environment.
            return null;
        }
    }
}
