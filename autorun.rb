require 'fileutils'

def make_src_file name
	file = File.new "Module.php", "w"
	file.puts "<?php"
	file.puts "\n"
	file.puts "namespace #{name};"
	file.puts "\n"
	file.puts "use Zend\\ModuleManager\\Feature\\ConfigProviderInterface;"
	file.puts "\n"
	file.puts "class Module implements ConfigProviderInterface"
	file.puts "{"
	file.puts "  public function getConfig()"
	file.puts "  {"
	file.puts "    return include __DIR__ . '/../config/module.config.php';"
	file.puts "  }"
	file.puts "}"
	file.close
	puts "created module.php"
end

def make_config_file name

  file = File.new "module.config.php", "w"
	file << "<?php\n"
content = <<PARAGRAPH
namespace Album;

use Zend\\Router\\Http\\Segment;
use Zend\\ServiceManager\\Factory\\InvokableFactory;

return [
    'controllers' => [
        'factories' => [
            Controller\\#{name.capitalize}Controller::class => InvokableFactory::class,
        ],
    ],

    'router' => [
        'routes' => [
            '#{name}' => [
                'type'    => Segment::class,
                'options' => [
                    'route' => '/#{name}[/:action[/:id]]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id'     => '[0-9]+',
                    ],
                    'defaults' => [
                        'controller' => Controller\\#{name.capitalize}Controller::class,
                        'action'     => 'index',
                    ],
                ],
            ],
        ],
    ],

    'view_manager' => [
        'template_path_stack' => [
            '#{name}' => __DIR__ . '/../view',
        ],
    ],
];
PARAGRAPH
	file << content
	file.close
	puts "created module.config.php"
end

def modify_composer_file name
  tempfile=File.open("file.tmp", 'w')
  f=File.new("composer.json")
  f.each do |line|
    tempfile<<line
    if line == "            \"Application\\\\\": \"module/Application/src/\"\n"
      tempfile.seek(-1, IO::SEEK_CUR)
      tempfile.puts ","
      tempfile << "            \"#{name}\\\\\": \"module/#{name}/src/\"\n"
    end
    if line == "            \"Application\\\\\": \"module/Application/src/\",\n"
      tempfile << "            \"#{name}\\\\\": \"module/#{name}/src/\",\n"
    end
  end
  f.close
  tempfile.close
  puts "modified composer.json"
  FileUtils.mv("file.tmp", "composer.json")
end

def modify_config_module_file name
	tempfile=File.open("file.tmp", 'w')
	f=File.new("modules.config.php")
	f.each do |line|
		tempfile<<line
		if line == "    'Application'\n"
			tempfile.seek(-1, IO::SEEK_CUR)
			tempfile.puts ","
			tempfile << "    '#{name}'\n"
		end
		if line == "    'Application',\n"
			tempfile << "    '#{name}',\n"
		end
	end
	f.close
	tempfile.close
	puts "modified /config/modules.config.php"
	FileUtils.mv("file.tmp", "modules.config.php")
end

def gen_module folder_name
	root_folder = folder_name.capitalize
	Dir.chdir "module"
  Dir.mkdir root_folder
	Dir.chdir root_folder
	Dir.mkdir "src"
	Dir.mkdir "config"
	Dir.mkdir "view"
	Dir.chdir "config"
	make_config_file folder_name
	Dir.chdir ".."
	Dir.chdir "src"
	make_src_file root_folder
	Dir.mkdir "Controller"
	Dir.mkdir "Form"
	Dir.mkdir "Model"
	Dir.chdir ".."
	Dir.chdir "view"
	Dir.mkdir "album"
	Dir.chdir "album"
	Dir.mkdir "album"
	Dir.chdir "../../../.."
	modify_composer_file root_folder
	Dir.chdir "config"
	modify_config_module_file root_folder
  puts "Created module #{root_folder}"
end

def gen_controller
	Dir.chdir "module/Album/src/Controller"
	f = File.new "#{name}Controller.php", "w"
content = <<PARA
<?php
namespace #{name}\\Controller;

use Zend\\Mvc\\Controller\\AbstractActionController;
use Zend\\View\\Model\\ViewModel;

class #{name}Controller extends AbstractActionController
{
    public function indexAction()
    {
    }

    public function addAction()
    {
    }

    public function editAction()
    {
    }

    public function deleteAction()
    {
    }
}
PARA
  f << content
	f.close
	puts "created #{name}controller "
end

def gen_entity intruction
	entity_name = intruction[0]
	intruction = intruction[1..-1]
	Dir.chdir "module"
	Dir.chdir "Application"
	Dir.chdir "src"
	Dir.chdir "Entity"
	file = File.new "{#entity_name}.php", "w"
prepara = <<PREPARA
<?php
namespace Application\\Entity;

use Doctrine\\ORM\\Mapping as ORM;

/**
 * @ORM\\Entity
 * @ORM\\Table(name="#{entity_name.downcase}s")
 */
class #{entity_name}
{
	/**
	 * @ORM\\Id
	 * @ORM\\GeneratedValue
	 * @ORM\\Column(name="id")
	 */
	protected $id;
			  // Returns ID of this post.
  public function getId() 
  {
    return $this->id;
  }

  // Sets ID of this post.
  public function setId($id) 
  {
    $this->id = $id;
  }

PREPARA

	file << prepara
	intruction.each do |attr|
	attribute = <<ATTR
	/**
	 * @ORM\\Column(name="#{attr}")
	 */
	protected $#{attr};

ATTR
	file << attribute
	end

	intruction.each do |attr|
		getseter = <<GETSETER

  public function get#{attr.capitalize}() 
  {
    return $this->#{attr};
  }

  public function set#{attr.capitalize}($#{attr}) 
  {
    $this->id = $#{attr};
  }
GETSETER
  file << getseter
	end
	file.close

end

instruction = []
ARGV.each do |a|
	instruction << a
end
if "g" == instruction[0]
	case instruction[1]
	when "module"
		gen_module instruction[2] if instruction[2]
		puts "you have to input module's name" unless instruction[2]
  when "controller"
		gen_controller instruction[2] if instruction[2]
		puts "you have to input controller's name" unless instruction[2]
  when "view"
		gen_view
	when "entity"
		instruction = instruction[2..-1]
		gen_entity instruction
	else
		puts "error"
	end
else
	puts "not a instruction"
end
