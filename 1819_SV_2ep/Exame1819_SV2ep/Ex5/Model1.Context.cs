﻿//------------------------------------------------------------------------------
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
    using System.Data.Entity;
    using System.Data.Entity.Infrastructure;
    using System.Data.Entity.Core.Objects;
    using System.Linq;
    
    public partial class Exame1819SV2epEntities : DbContext
    {
        public Exame1819SV2epEntities()
            : base("name=Exame1819SV2epEntities")
        {
        }
    
        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            throw new UnintentionalCodeFirstException();
        }
    
        public virtual DbSet<manutencao> manutencaos { get; set; }
        public virtual DbSet<manutencaoItem> manutencaoItems { get; set; }
        public virtual DbSet<veiculo> veiculoes { get; set; }
    
        public virtual int insereManutencaoItem(string mat, Nullable<int> km, Nullable<int> linha, Nullable<decimal> valor)
        {
            var matParameter = mat != null ?
                new ObjectParameter("mat", mat) :
                new ObjectParameter("mat", typeof(string));
    
            var kmParameter = km.HasValue ?
                new ObjectParameter("km", km) :
                new ObjectParameter("km", typeof(int));
    
            var linhaParameter = linha.HasValue ?
                new ObjectParameter("linha", linha) :
                new ObjectParameter("linha", typeof(int));
    
            var valorParameter = valor.HasValue ?
                new ObjectParameter("valor", valor) :
                new ObjectParameter("valor", typeof(decimal));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("insereManutencaoItem", matParameter, kmParameter, linhaParameter, valorParameter);
        }
    
        public virtual int insereManutencaoItem2(string mat, Nullable<int> km, Nullable<int> linha, Nullable<decimal> valor)
        {
            var matParameter = mat != null ?
                new ObjectParameter("mat", mat) :
                new ObjectParameter("mat", typeof(string));
    
            var kmParameter = km.HasValue ?
                new ObjectParameter("km", km) :
                new ObjectParameter("km", typeof(int));
    
            var linhaParameter = linha.HasValue ?
                new ObjectParameter("linha", linha) :
                new ObjectParameter("linha", typeof(int));
    
            var valorParameter = valor.HasValue ?
                new ObjectParameter("valor", valor) :
                new ObjectParameter("valor", typeof(decimal));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("insereManutencaoItem2", matParameter, kmParameter, linhaParameter, valorParameter);
        }
    }
}
