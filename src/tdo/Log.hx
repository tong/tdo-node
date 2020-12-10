package tdo;

typedef Entry = {
    context : String,
    message : String,
    timeStart : Date,
};

class Log {

    public static inline var DEFAULT_PATH = '/home/tong/dev/tool/tdo-node/tdo.log';

    public final path : String;
    
    public var data : Array<Dynamic>;

    function new( path : String, data : Array<Entry> ) {
        this.path = path;
        this.data = data;
    }

    public function add( entry : Entry ) {
        data.push( {
            context: entry.context,
            message: entry.message,
            timeStart : entry.timeStart
        } );
    }

    public function save() {
        Fs.writeFileSync( path, Json.stringify( data ) );
    }

    public static function init( path : String ) : Promise<Log> {
        return new Promise( (resolve,reject) -> {
            Fs.readFile( path, (e,r) -> {
                if( e != null ) reject(e) else {
                    var data = Json.parse(r.toString());
                    var log = new Log( path, data );
                    resolve( log );
                }
            } );
        });
    }
}