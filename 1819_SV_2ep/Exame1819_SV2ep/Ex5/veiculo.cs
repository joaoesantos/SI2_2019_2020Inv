//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated from a template.
//
//     Manual changes to this file may cause unexpected behavior in your application.
//     Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace Ex5
{
    using System;
    using System.Collections.Generic;
    
    public partial class veiculo
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public veiculo()
        {
            this.manutencaos = new HashSet<manutencao>();
        }
    
        public string matricula { get; set; }
        public Nullable<int> kmActuais { get; set; }
        public string descr { get; set; }
    
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<manutencao> manutencaos { get; set; }
    }
}