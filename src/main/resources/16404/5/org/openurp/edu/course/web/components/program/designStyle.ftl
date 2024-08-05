 <style>
    body{
      font-family:'Times New Roman',宋体;
      font-size: 12pt;
      margin:auto;
    }
    .cover-table .title{
      font-size: 14pt;
    }
    td{
      padding-left:5px;
    }
    .title {
      text-align: center;
      font-weight: 700;
    }
   .title-left{
      text-align: left;
      font-weight: 700;
    }
    p{
      margin-bottom:0rem;
      margin-top:0rem;
    }
    .cover-table {
      margin:auto;
    }
    .grid-table {
      width:100%;
      border: solid 0.5px black;
      border-collapse: collapse;
    }
    .grid-table td,th{
      border:0.5px solid black;
    }
    .container {
      width: 100%;
      margin-right: auto;
      margin-left: auto;
    }
    .logo-container{
      width:58mm;
      text-align:center;
      margin:0px auto 0px auto;
    }
    @media (min-width: 1200px) {
      .container {
        max-width: 1140px;
      }
    }
    @media print {
      .cover-table {
        margin:auto;
        margin-top:150px;
      }
      body{
        width:170mm;
      }
      .logo-container{
        margin:100px auto 0px auto;
      }
      @page  {
        size: A4;
        margin:18mm 18mm;
      }
    }
  </style>
