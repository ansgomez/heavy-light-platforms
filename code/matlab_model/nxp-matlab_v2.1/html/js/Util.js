var summaryColNames = ["CPU", "Tasks", "Jobs", "Missed(%)", "Total Energy (uJ)", "Simulation time (ms)"];
var procColNames = ["ID", "Frequency(MHz)", "CPI", "Active Power(mW)", "Idle Power(mW)", "Total Energy(uJ)", "Utilization(%)"];
var queueColNames = ["Task ID", "Job ID", "Arrival Time(ms)", "Start Time(ms)", "Finish Time(ms)", "Deadline(ms)", "Instructions", "Allocated CPU", "Job Energy(uJ)"];

function tabulate(name, data, columns, colnames) {
    d3.select("#table_container").append("h3").text(name);
    var table = d3.select("#table_container").append("table"),
        thead = table.append("thead"),
        tbody = table.append("tbody");

    // append the header row
    thead.append("tr")
        .selectAll("th")
        .data(columns)
        .enter()
        .append("th")
        .text(function(column) { return colnames[column];; });

    // create a row for each object in the data
    var rows = tbody.selectAll("tr")
        .data(data)
        .enter()
        .append("tr");

    // create a cell in each row for each column
    var cells = rows.selectAll("td")
        .data(function(row) {
            return columns.map(function(column) {
                return {column: column, value: row[column]};
            });
        })
        .enter()
        .append("td")
        .text(function(d) { return d.value; });
    
    return table;
}

function tabulateVertical(name, data, columns, colnames) {
    //todo
}

function createGraphTable(cores){
    var body = document.body,
        div  = document.createElement('div');
        tbl  = document.createElement('table');
    
    div.id="images";
    div.style.class = 'row';

    for(var i = cores; i >= 1; i--){
        //insert column names
        var tr1 = tbl.insertRow();
          var td2 = tr1.insertCell();
          td2.appendChild(document.createTextNode('Core '+i+' Schedule:'));
          var td1 = tr1.insertCell();
          td1.appendChild(document.createTextNode('Core '+i+' Energy:'));
		
        //insert graphs
        var tr2 = tbl.insertRow()    
          //add sched img
          var td4 = tr2.insertCell();
          var img2 = document.createElement('img');
          img2.src = "sim/core"+i+"_curr_job_v_time.png";;
          //img.height = 200;
          img2.width=200;
          td4.appendChild(img2);
          //add energy img
          var td3 = tr2.insertCell();
          var img = document.createElement('img');
          img.src = "sim/core"+i+"_energy_v_time.png";;
          //img.height = 200;
          img.width=200;
          td3.appendChild(img);
          
    }

    div.appendChild(tbl);
    body.appendChild(div);
}
 