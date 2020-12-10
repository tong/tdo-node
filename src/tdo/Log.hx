package tdo;

typedef Entry = {
    user : String,
    context : String,
    message : String,
    time : Date,
};

class Log {

    public static inline var DEFAULT_PATH = '/home/tong/dev/tool/tdo-node/log.json';

    public final path : String;
    
    public var data : Array<Dynamic>;

    function new( path : String, data : Array<Entry> ) {
        this.path = path;
        this.data = data;
    }

    public function add( entry : Entry ) {
        data.push( {
            user: entry.user,
            context: entry.context,
            message: entry.message,
            time : entry.time
            //elapsed : entry.elapsed
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